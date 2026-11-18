//! 11 — Radar / minimap
//!
//! A circular radar in one of four corners. Contacts are placed on the
//! ground plane (XZ) relative to the local avatar, at `radius / range` pixels
//! per meter. With `rotate_with_view` up is the view heading; otherwise up is
//! +X.

const sdk = @import("sdk");

const Settings = sdk.Settings("Radar", struct {
    enabled: bool = true,
    size: u32 = 180,
    range: f32 = 60.0,
    position: u32 = 3,
    rotate_with_view: bool = true,
    show_allies: bool = true,
    enemy_color: u32 = 0xFFFF5C5C,
    ally_color: u32 = 0xFF5CD0FF,
    self_color: u32 = 0xFFFFFFFF,
}, .{
    .enabled = .{ .display_name = "Enabled" },
    .size = .{ .display_name = "Size (px)", .control = "slider", .min = 90, .max = 340 },
    .range = .{ .display_name = "Range (m)", .control = "slider", .min = 10.0, .max = 200.0 },
    .position = .{
        .display_name = "Position",
        .control = "multi",
        .options = .{ "top-left", "top-right", "bottom-left", "bottom-right" },
    },
    .rotate_with_view = .{ .display_name = "Rotate With View" },
    .show_allies = .{ .display_name = "Show Allies" },
    .enemy_color = .{ .display_name = "Enemy Color", .control = "color" },
    .ally_color = .{ .display_name = "Ally Color", .control = "color" },
    .self_color = .{ .display_name = "Self Color", .control = "color" },
});

const MARGIN: f32 = 18.0;

/// Settings colors are `0xAARRGGBB`; draw calls take `0xAABBGGRR`.
fn color(argb: u32) i32 {
    return @bitCast(sdk.util.argbToHost(argb));
}

/// Center of a radar of `radius` in the configured corner of the viewport.
fn centerFor(vp: sdk.Vec2, radius: f32) sdk.Vec2 {
    const left = MARGIN + radius;
    const right = vp.x - MARGIN - radius;
    const top = MARGIN + radius;
    const bottom = vp.y - MARGIN - radius;
    return switch (Settings.data.position) {
        0 => sdk.Vec2.init(left, top),
        1 => sdk.Vec2.init(right, top),
        2 => sdk.Vec2.init(left, bottom),
        else => sdk.Vec2.init(right, bottom),
    };
}

export fn onFrame(_: f32, _: i32) void {
    if (!Settings.data.enabled) return;

    const local = sdk.localActor() orelse return;
    const avatar = local.avatar orelse return;

    const vp = sdk.render.viewport();
    if (vp.x <= 0.0 or vp.y <= 0.0) return;

    const radius = @as(f32, @floatFromInt(Settings.data.size)) * 0.5;
    const center = centerFor(vp, radius);
    const range = @max(1.0, Settings.data.range);
    const scale = radius / range;

    sdk.render.drawCircle(center.x, center.y, radius, sdk.rgba(0, 0, 0, 165), true);
    sdk.render.drawCircle(center.x, center.y, radius, sdk.rgba(120, 200, 255, 190), false);
    sdk.render.drawCircle(center.x, center.y, radius * 0.5, sdk.rgba(120, 200, 255, 70), false);
    const sweep = sdk.frameTime() * 1.5;
    sdk.render.drawLine(
        center.x,
        center.y,
        center.x + sdk.sinf(sweep) * radius,
        center.y - sdk.cosf(sweep) * radius,
        sdk.rgba(120, 255, 160, 110),
    );

    // Ground-plane basis: `f` is the radar's up axis, `r` its right axis.
    const yaw = if (Settings.data.rotate_with_view) sdk.util.math.yawPitch(local.last_view_direction).x else 0.0;
    const fx = sdk.cosf(yaw);
    const fz = sdk.sinf(yaw);
    const origin = avatar.transform.position;

    var contacts: u32 = 0;
    for (sdk.actors()) |*actor| {
        if (actor.id == avatar.id) continue;
        const ally = actor.team == .ally;
        if (!ally and actor.team != .enemy) continue;
        if (ally and !Settings.data.show_allies) continue;
        if (actor.max_health > 0.0 and actor.health <= 0.0) continue; // dead

        const d = actor.transform.position.sub(origin);
        const forward = d.x * fx + d.z * fz;
        const right = d.z * fx - d.x * fz;
        if (forward * forward + right * right > range * range) continue;

        const px = center.x + right * scale - 3.0;
        const py = center.y - forward * scale - 3.0;
        sdk.render.drawFilledRect(px, py, 6.0, 6.0, color(if (ally) Settings.data.ally_color else Settings.data.enemy_color));
        contacts += 1;
    }

    sdk.render.drawCircle(center.x, center.y, 3.5, color(Settings.data.self_color), true);

    sdk.render.drawTextFmt("range {d:.0}m", .{range}, center.x - radius, center.y + radius + 4.0, 11.0, sdk.rgba(200, 200, 200, 255));
    sdk.render.drawTextCenteredFmt("{d} contacts", .{contacts}, center.x, center.y - radius - 16.0, 11.0, sdk.rgba(200, 200, 200, 255));
}
