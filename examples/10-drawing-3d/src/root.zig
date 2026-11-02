//! 10 — 3D primitives
//!
//! Spheres, capsules, and boxes drawn in world space in three styles:
//! wireframe, filled, and gradient. One of each primitive is stacked above
//! the local avatar; visible enemy actors are drawn from their hitboxes,
//! or as a box from the actor transform when they have none.
//! Positions, radii, and half-extents are in meters.

const sdk = @import("sdk");

const Settings = sdk.Settings("3D Primitives", struct {
    enabled: bool = true,
    mode: u32 = 0,
    accent: u32 = 0xFFFFD166,
    max_distance: f32 = 70.0,
}, .{
    .enabled = .{ .display_name = "Enabled" },
    .mode = .{
        .display_name = "Style",
        .control = "multi",
        .options = .{ "Wireframe", "Filled", "Gradient" },
    },
    .accent = .{ .display_name = "Accent Color", .control = "color" },
    .max_distance = .{ .display_name = "Max Distance (m)", .control = "slider", .min = 5.0, .max = 150.0 },
});

/// Settings colors are `0xAARRGGBB`; draw calls take `0xAABBGGRR`.
fn color(argb: u32) i32 {
    return @bitCast(sdk.util.argbToHost(argb));
}

const UP = sdk.Vec3.init(0.0, 1.0, 0.0);

/// One hitbox set in the selected style. Gradients blend from `fill` to
/// `accent` along world up (spheres and boxes) or from `a` to `b` (capsules).
fn drawSet(set: sdk.HitboxSet, mode: u32, fill: i32, accent: i32) void {
    for (set.spheres) |s| switch (mode) {
        0 => sdk.render.drawWireSphere3D(s.shape.center, s.shape.radius, fill),
        1 => sdk.render.drawSphere3D(s.shape.center, s.shape.radius, fill),
        else => sdk.render.drawGradientSphere3D(s.shape.center, s.shape.radius, fill, accent, UP),
    };
    for (set.capsules) |c| switch (mode) {
        0 => sdk.render.drawWireCapsule3D(c.shape.a, c.shape.b, c.shape.radius, fill),
        1 => sdk.render.drawCapsule3D(c.shape.a, c.shape.b, c.shape.radius, fill),
        else => sdk.render.drawGradientCapsule3D(c.shape.a, c.shape.b, c.shape.radius, fill, accent),
    };
    for (set.boxes) |b| switch (mode) {
        0 => sdk.render.drawBox3DWireframe(b.shape.center, b.shape.half_extents, b.shape.rotation, fill),
        1 => sdk.render.drawBox3D(b.shape.center, b.shape.half_extents, b.shape.rotation, fill),
        else => sdk.render.drawGradientBox3D(b.shape.center, b.shape.half_extents, b.shape.rotation, fill, accent, UP),
    };
}

export fn onFrame(_: f32, _: i32) void {
    if (!Settings.data.enabled or !sdk.camera.active()) return;

    const avatar = (sdk.localActor() orelse return).avatar orelse return;
    const mode = Settings.data.mode;
    const accent = color(Settings.data.accent);
    const origin = avatar.transform.position;

    var spheres = [_]sdk.SphereHitbox{.{
        .shape = .{ .center = origin.add(UP.scale(3.0)), .radius = 0.4 },
        .bone = -1,
        .critical = false,
    }};
    var capsules = [_]sdk.CapsuleHitbox{.{
        .shape = .{ .a = origin.add(UP.scale(1.6)), .b = origin.add(UP.scale(2.3)), .radius = 0.3 },
        .bone = -1,
        .critical = false,
    }};
    var boxes = [_]sdk.BoxHitbox{.{
        .shape = .{
            .center = origin.add(UP.scale(0.6)),
            .half_extents = sdk.Vec3.init(0.35, 0.5, 0.35),
            .rotation = avatar.transform.rotation,
        },
    }};
    drawSet(.{ .spheres = &spheres, .capsules = &capsules, .boxes = &boxes }, mode, sdk.rgba(120, 220, 140, 255), accent);

    for (sdk.actors()) |*actor| {
        if (actor.team != .enemy or !actor.is_visible) continue;
        if (actor.transform.position.dist(origin) > Settings.data.max_distance) continue;

        const enemy_color = sdk.rgba(255, 120, 120, 255);
        if (actor.hitboxes) |set| {
            drawSet(set.*, mode, enemy_color, accent);
        } else {
            var fallback = [_]sdk.BoxHitbox{.{
                .shape = .{
                    .center = actor.transform.position.add(UP.scale(0.9)),
                    .half_extents = sdk.Vec3.init(0.35, 0.9, 0.35),
                    .rotation = actor.transform.rotation,
                },
            }};
            drawSet(.{ .spheres = &.{}, .capsules = &.{}, .boxes = &fallback }, mode, enemy_color, accent);
        }
    }
}
