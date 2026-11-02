//! 07 — Actor boxes: world-to-screen projection
//!
//! A 2D box around every visible enemy actor, built from the projected
//! extremes of its hitboxes, or from the actor's position when it has
//! none. `sdk.camera.w2s` returns logical pixels with y down, or null for
//! points behind the camera or with no projector; projected points can land
//! outside the viewport.

const sdk = @import("sdk");

const Settings = sdk.Settings("Actor Boxes", struct {
    enabled: bool = true,
    box_color: u32 = 0xFF44DD66,
    max_distance: f32 = 80.0,
    show_distance: bool = true,
}, .{
    .enabled = .{ .display_name = "Enabled" },
    .box_color = .{ .display_name = "Box Color", .control = "color" },
    .max_distance = .{ .display_name = "Max Distance (m)", .control = "slider", .min = 5.0, .max = 200.0 },
    .show_distance = .{ .display_name = "Show Distance" },
});

const Bounds = struct {
    min_x: f32,
    min_y: f32,
    max_x: f32,
    max_y: f32,
};

/// Project `p` and grow the screen-space bounds by it.
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

/// Screen-space bounds of an actor's hitboxes.
fn actorBounds(actor: *const sdk.Actor) ?Bounds {
    var bounds: ?Bounds = null;

    if (actor.hitboxes) |set| {
        for (set.spheres) |sphere| {
            // The six axis extremes approximate the projected sphere.
            extend(&bounds, sphere.shape.center.add(sdk.Vec3.init(sphere.shape.radius, 0.0, 0.0)));
            extend(&bounds, sphere.shape.center.sub(sdk.Vec3.init(sphere.shape.radius, 0.0, 0.0)));
            extend(&bounds, sphere.shape.center.add(sdk.Vec3.init(0.0, sphere.shape.radius, 0.0)));
            extend(&bounds, sphere.shape.center.sub(sdk.Vec3.init(0.0, sphere.shape.radius, 0.0)));
            extend(&bounds, sphere.shape.center.add(sdk.Vec3.init(0.0, 0.0, sphere.shape.radius)));
            extend(&bounds, sphere.shape.center.sub(sdk.Vec3.init(0.0, 0.0, sphere.shape.radius)));
        }
        for (set.capsules) |capsule| {
            const r = sdk.Vec3.init(capsule.shape.radius, capsule.shape.radius, capsule.shape.radius);
            extend(&bounds, capsule.shape.a.add(r));
            extend(&bounds, capsule.shape.a.sub(r));
            extend(&bounds, capsule.shape.b.add(r));
            extend(&bounds, capsule.shape.b.sub(r));
        }
        for (set.boxes) |box| {
            inline for ([_]f32{ -1.0, 1.0 }) |sx| {
                inline for ([_]f32{ -1.0, 1.0 }) |sy| {
                    inline for ([_]f32{ -1.0, 1.0 }) |sz| {
                        const local = sdk.Vec3.init(
                            sx * box.shape.half_extents.x,
                            sy * box.shape.half_extents.y,
                            sz * box.shape.half_extents.z,
                        );
                        extend(&bounds, box.shape.center.add(box.shape.rotation.rotateVec3(local)));
                    }
                }
            }
        }
    }

    if (bounds == null) {
        // No hitboxes: a 0.8 m wide box from the actor's feet to head.
        const p = actor.transform.position;
        for ([_]f32{ 0.0, 1.8 }) |up| {
            extend(&bounds, p.add(sdk.Vec3.init(0.4, up, 0.4)));
            extend(&bounds, p.add(sdk.Vec3.init(-0.4, up, -0.4)));
        }
    }

    return bounds;
}

export fn onFrame(_: f32, _: i32) void {
    if (!Settings.data.enabled or !sdk.camera.active()) return;

    const local = sdk.localActor() orelse return;
    const avatar = local.avatar orelse return;
    const vp = sdk.render.viewport();
    if (vp.x <= 0.0 or vp.y <= 0.0) return;

    const shade: i32 = @bitCast(sdk.util.argbToHost(Settings.data.box_color));

    for (sdk.actors()) |*actor| {
        if (actor.team != .enemy) continue;
        if (actor.max_health > 0.0 and actor.health <= 0.0) continue; // dead
        if (!actor.is_visible) continue;

        const distance = avatar.transform.position.dist(actor.transform.position);
        if (distance > Settings.data.max_distance) continue;

        const bounds = actorBounds(actor) orelse continue;
        const w = bounds.max_x - bounds.min_x;
        const h = bounds.max_y - bounds.min_y;
        if (w < 1.0 or h < 1.0) continue;

        if (bounds.max_x < 0.0 or bounds.min_x > vp.x) continue;
        if (bounds.max_y < 0.0 or bounds.min_y > vp.y) continue;

        sdk.render.drawRect(bounds.min_x, bounds.min_y, w, h, shade, 1.5);

        // Corner ticks.
        const tick = @min(8.0, @min(w, h) * 0.25);
        sdk.render.drawLine(bounds.min_x, bounds.min_y, bounds.min_x + tick, bounds.min_y, shade);
        sdk.render.drawLine(bounds.min_x, bounds.min_y, bounds.min_x, bounds.min_y + tick, shade);
        sdk.render.drawLine(bounds.max_x, bounds.min_y, bounds.max_x - tick, bounds.min_y, shade);
        sdk.render.drawLine(bounds.max_x, bounds.min_y, bounds.max_x, bounds.min_y + tick, shade);
        sdk.render.drawLine(bounds.min_x, bounds.max_y, bounds.min_x + tick, bounds.max_y, shade);
        sdk.render.drawLine(bounds.min_x, bounds.max_y, bounds.min_x, bounds.max_y - tick, shade);
        sdk.render.drawLine(bounds.max_x, bounds.max_y, bounds.max_x - tick, bounds.max_y, shade);
        sdk.render.drawLine(bounds.max_x, bounds.max_y, bounds.max_x, bounds.max_y - tick, shade);

        if (Settings.data.show_distance) {
            sdk.render.drawTextCenteredFmt("{d:.0}m", .{distance}, bounds.min_x + w * 0.5, bounds.min_y - 14.0, 11.0, shade);
        }
    }
}
