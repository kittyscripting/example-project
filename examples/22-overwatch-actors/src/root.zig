//! 22 — overwatch actors
//!
//! Labels live actors from what the provider publishes on each `sdk.Actor`:
//! behavioural `kind`, distance, and hitbox volume count. Each actor in the
//! `overwatch` package, a hero such as `app.actor.sierra` or a family such
//! as `app.actor.turret`, exposes only `eq`, which tells whether a live
//! actor's `type_id` belongs to it; everything else about the actor is on the
//! live actor. Turrets, explosives, and support deployables are actors too;
//! `sdk.helpers.target.isObject` tells them apart.

const sdk = @import("sdk");
const app = @import("overwatch");

const Settings = sdk.Settings("overwatch Actors", struct {
    enabled: bool = true,
    max_distance: f32 = 60.0,
    actor_color: u32 = 0xFFB4B4B4,
    turret_color: u32 = 0xFF7FE3FF,
    object_color: u32 = 0xFFFFC46B,
}, .{
    .enabled = .{ .display_name = "Enabled" },
    .max_distance = .{ .display_name = "Max Distance (m)", .control = "slider", .min = 10.0, .max = 200.0 },
    .actor_color = .{ .display_name = "Actor Color", .control = "color" },
    .turret_color = .{ .display_name = "Turret Color", .control = "color" },
    .object_color = .{ .display_name = "Object Color", .control = "color" },
});

/// Color settings are `0xAARRGGBB`; draw calls take `0xAABBGGRR`.
fn drawColor(argb: u32) i32 {
    return @bitCast(sdk.util.argbToHost(argb));
}

/// Number of hitbox volumes the provider publishes for `actor`.
fn volumeCount(actor: *const sdk.Actor) usize {
    const set = actor.hitboxes orelse return 0;
    return set.spheres.len + set.capsules.len + set.boxes.len;
}

export fn onFrame(_: f32, _: i32) void {
    if (!Settings.data.enabled or !sdk.camera.active()) return;

    const vp = sdk.render.viewport();
    if (vp.x <= 0.0 or vp.y <= 0.0) return;
    const avatar = (sdk.localActor() orelse return).avatar orelse return;

    var turret_count: u32 = 0;
    var object_count: u32 = 0;
    var other_count: u32 = 0;

    for (sdk.actors()) |*actor| {
        if (actor.id == avatar.id) continue;
        const distance = avatar.transform.position.dist(actor.transform.position);
        if (distance > Settings.data.max_distance) continue;

        const turret = app.actor.turret.eq(actor.type_id);
        const object = sdk.helpers.target.isObject(actor);
        if (turret) turret_count += 1 else if (object) object_count += 1 else other_count += 1;

        const shade = drawColor(if (turret)
            Settings.data.turret_color
        else if (object)
            Settings.data.object_color
        else
            Settings.data.actor_color);

        const screen = sdk.camera.w2s(actor.transform.position) orelse continue;
        if (object) sdk.render.drawCircle(screen.x, screen.y, 4.0, shade, false);
        sdk.render.drawTextCenteredFmt("{s}  {d:.0}m  {d} volumes", .{
            @tagName(actor.kind),
            distance,
            volumeCount(actor),
        }, screen.x, screen.y - 16.0, 11.0, shade);
    }

    sdk.render.drawFilledRect(12.0, 12.0, 320.0, 28.0, sdk.rgba(0, 0, 0, 165));
    sdk.render.drawTextFmt("turrets: {d}   objects: {d}   other: {d}", .{
        turret_count,
        object_count,
        other_count,
    }, 22.0, 20.0, 12.0, sdk.rgba(225, 225, 225, 255));
}
