//! 13 — Trace and line of sight
//!
//! Casts from the camera eye to the aim point of each enemy actor in range
//! and reports whether the segment is blocked. The trace skips the local
//! actor; a hit on the target itself is the segment ending at the target, not
//! an obstruction. `from`, `to`, and `position` are world meters; `entity` is
//! -1 for geometry hits and misses.

const sdk = @import("sdk");

const Settings = sdk.Settings("Trace", struct {
    enabled: bool = true,
    max_distance: f32 = 80.0,
    show_clear: bool = true,
    show_blocked: bool = true,
}, .{
    .enabled = .{ .display_name = "Enabled" },
    .max_distance = .{ .display_name = "Max Distance (m)", .control = "slider", .min = 5.0, .max = 200.0 },
    .show_clear = .{ .display_name = "Mark Clear Targets" },
    .show_blocked = .{ .display_name = "Mark Blocked Targets" },
});

export fn onFrame(_: f32, _: i32) void {
    if (!Settings.data.enabled) return;

    const local = sdk.localActor() orelse return;
    const avatar = local.avatar orelse return;
    const eye = sdk.camera.position() orelse return;
    const view = local.last_view_direction;
    const start = eye.add(view.scale(0.5)); // just ahead of the eye

    for (sdk.actors()) |*actor| {
        if (actor.team != .enemy) continue;
        if (actor.transform.position.dist(avatar.transform.position) > Settings.data.max_distance) continue;

        const target = sdk.helpers.target.pickAimPoint(actor, .defined, eye, view) orelse continue;

        const result = sdk.trace.trace(eye, target, avatar.id, .everything);
        const blocked = result.hit and result.entity != actor.id;
        if (blocked and !Settings.data.show_blocked) continue;
        if (!blocked and !Settings.data.show_clear) continue;

        const shade = if (blocked) sdk.rgba(255, 80, 80, 220) else sdk.rgba(80, 255, 120, 200);
        const end = sdk.camera.w2s(result.position) orelse continue;
        if (sdk.camera.w2s(start)) |a| sdk.render.drawLine(a.x, a.y, end.x, end.y, shade);
        sdk.render.drawCircle(end.x, end.y, 5.0, shade, false);
        if (blocked) {
            sdk.render.drawTextFmt("blocked (entity {d})", .{result.entity}, end.x + 8.0, end.y - 6.0, 11.0, shade);
        } else {
            sdk.render.drawText("clear", end.x + 8.0, end.y - 6.0, 11.0, shade);
        }
    }
}
