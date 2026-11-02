//! 08 — Health bars
//!
//! A health bar above every visible enemy actor with a green → yellow →
//! red fill, 3 px strips for shield, armor, and overhealth pools above it,
//! and a border while the actor cannot be damaged. `max_health <= 0` means
//! the actor reports no health.

const sdk = @import("sdk");

const Settings = sdk.Settings("Health Bars", struct {
    enabled: bool = true,
    max_distance: f32 = 90.0,
    show_values: bool = true,
    bar_height: u32 = 5,
}, .{
    .enabled = .{ .display_name = "Enabled" },
    .max_distance = .{ .display_name = "Max Distance (m)", .control = "slider", .min = 5.0, .max = 200.0 },
    .show_values = .{ .display_name = "Show HP Text" },
    .bar_height = .{ .display_name = "Bar Height (px)", .control = "slider", .min = 2, .max = 12 },
});

const Bounds = struct { min_x: f32, min_y: f32, max_x: f32, max_y: f32 };

fn extend(bounds: *?Bounds, p: sdk.Vec3) void {
    const screen = sdk.camera.w2s(p) orelse return;
    if (bounds.*) |*b| {
        b.min_x = @min(b.min_x, screen.x);
        b.min_y = @min(b.min_y, screen.y);
        b.max_x = @max(b.max_x, screen.x);
        b.max_y = @max(b.max_y, screen.y);
    } else {
        bounds.* = .{ .min_x = screen.x, .min_y = screen.y, .max_x = screen.x, .max_y = screen.y };
    }
}

/// Head-to-toe screen extent, used to anchor the bar.
fn bodyBounds(actor: *const sdk.Actor) ?Bounds {
    var bounds: ?Bounds = null;
    const up = sdk.Vec3.init(0.0, 1.0, 0.0);
    if (actor.hitboxes) |set| {
        for (set.spheres) |s| {
            extend(&bounds, s.shape.center.add(up.scale(s.shape.radius)));
            extend(&bounds, s.shape.center.sub(up.scale(s.shape.radius)));
        }
        for (set.capsules) |c| {
            for ([_]sdk.Vec3{ c.shape.a, c.shape.b }) |end| {
                extend(&bounds, end.add(up.scale(c.shape.radius)));
                extend(&bounds, end.sub(up.scale(c.shape.radius)));
            }
        }
        for (set.boxes) |b| {
            const half = up.scale(b.shape.half_extents.y);
            extend(&bounds, b.shape.center.add(half));
            extend(&bounds, b.shape.center.sub(half));
        }
    }
    if (bounds == null) {
        const p = actor.transform.position;
        extend(&bounds, p);
        extend(&bounds, p.add(up.scale(1.7)));
    }
    return bounds;
}

fn healthColor(fraction: f32) i32 {
    if (fraction > 0.6) return sdk.rgba(90, 220, 120, 255);
    if (fraction > 0.3) return sdk.rgba(240, 200, 60, 255);
    return sdk.rgba(240, 80, 80, 255);
}

export fn onFrame(_: f32, _: i32) void {
    if (!Settings.data.enabled or !sdk.camera.active()) return;

    const local = sdk.localActor() orelse return;
    const avatar = local.avatar orelse return;

    for (sdk.actors()) |*actor| {
        if (actor.team != .enemy) continue;
        if (!actor.is_visible) continue;
        if (actor.max_health <= 0.0 or actor.health <= 0.0) continue;

        const distance = avatar.transform.position.dist(actor.transform.position);
        if (distance > Settings.data.max_distance) continue;

        const bounds = bodyBounds(actor) orelse continue;
        const span = bounds.max_x - bounds.min_x;
        const width = @max(46.0, span);
        const x = bounds.min_x - (width - span) * 0.5;
        const bar_h: f32 = @floatFromInt(Settings.data.bar_height);
        const bar_y = bounds.min_y - (bar_h + 8.0);
        const fraction = sdk.clampf(actor.health / actor.max_health, 0.0, 1.0);

        sdk.render.drawFilledRect(x - 1.0, bar_y - 1.0, width + 2.0, bar_h + 2.0, sdk.rgba(0, 0, 0, 210));
        sdk.render.drawFilledRect(x, bar_y, width * fraction, bar_h, healthColor(fraction));

        // Pool strips stack upward; `top` tracks their upper edge.
        var top = bar_y;
        if (actor.health_pools) |pools| {
            for ([_]sdk.HealthPoolKind{ .shield, .armor, .overhealth }) |kind| {
                const pool = pools.ofKind(kind) orelse continue;
                if (pool.max <= 0.0) continue;
                const shade = switch (kind) {
                    .shield => sdk.rgba(90, 170, 255, 255),
                    .armor => sdk.rgba(255, 210, 90, 255),
                    else => sdk.rgba(200, 120, 255, 255),
                };
                top -= 4.0;
                sdk.render.drawFilledRect(x, top, width, 3.0, sdk.rgba(0, 0, 0, 200));
                sdk.render.drawFilledRect(x, top, width * sdk.clampf(pool.current / pool.max, 0.0, 1.0), 3.0, shade);
            }
        }

        if (Settings.data.show_values) {
            sdk.render.drawTextCenteredFmt("{d:.0} / {d:.0}", .{ actor.health, actor.max_health }, x + width * 0.5, top - 14.0, 11.0, sdk.rgba(230, 230, 230, 255));
        }

        if (actor.is_invincible) {
            sdk.render.drawRect(x - 2.0, bar_y - 2.0, width + 4.0, bar_h + 4.0, sdk.rgba(255, 255, 255, 220), 1.0);
        }
    }
}
