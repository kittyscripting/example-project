//! 09 — Skeletons and bones
//!
//! Skeletons of visible enemy actors: a line per parent→child bone pair,
//! a dot at every joint, and a ring around each critical (head) hitbox.
//! `Skeleton.lines()` returns a shared buffer that the next call overwrites.

const sdk = @import("sdk");

const Settings = sdk.Settings("Skeleton", struct {
    enabled: bool = true,
    bone_color: u32 = 0xFF7FE3FF,
    joint_color: u32 = 0xFFFFFFFF,
    head_color: u32 = 0xFFFF5C8A,
    max_distance: f32 = 60.0,
    show_joints: bool = true,
}, .{
    .enabled = .{ .display_name = "Enabled" },
    .bone_color = .{ .display_name = "Bone Color", .control = "color" },
    .joint_color = .{ .display_name = "Joint Color", .control = "color" },
    .head_color = .{ .display_name = "Head Marker Color", .control = "color" },
    .max_distance = .{ .display_name = "Max Distance (m)", .control = "slider", .min = 5.0, .max = 150.0 },
    .show_joints = .{ .display_name = "Show Joints" },
});

/// Settings colors are `0xAARRGGBB`; draw calls take `0xAABBGGRR`.
fn color(argb: u32) i32 {
    return @bitCast(sdk.util.argbToHost(argb));
}

fn ring(center: sdk.Vec3, shade: i32) void {
    const p = sdk.camera.w2s(center) orelse return;
    sdk.render.drawCircle(p.x, p.y, 6.0, shade, false);
}

export fn onFrame(_: f32, _: i32) void {
    if (!Settings.data.enabled or !sdk.camera.active()) return;

    const avatar = (sdk.localActor() orelse return).avatar orelse return;
    const bone_color = color(Settings.data.bone_color);
    const joint_color = color(Settings.data.joint_color);
    const head_color = color(Settings.data.head_color);

    for (sdk.actors()) |*actor| {
        if (actor.team != .enemy or !actor.is_visible) continue;
        if (actor.transform.position.dist(avatar.transform.position) > Settings.data.max_distance) continue;

        if (actor.skeleton) |skeleton| {
            for (skeleton.lines()) |segment| {
                const from = sdk.camera.w2s(segment.from) orelse continue;
                const to = sdk.camera.w2s(segment.to) orelse continue;
                sdk.render.drawLine(from.x, from.y, to.x, to.y, bone_color);
            }
            if (Settings.data.show_joints) {
                for (skeleton.bones) |bone| {
                    const p = sdk.camera.w2s(bone.position) orelse continue;
                    sdk.render.drawFilledRect(p.x - 1.5, p.y - 1.5, 3.0, 3.0, joint_color);
                }
            }
        }

        if (actor.hitboxes) |set| {
            for (set.spheres) |s| if (s.critical) ring(s.shape.center, head_color);
            for (set.capsules) |c| if (c.critical) ring(c.shape.a.lerp(c.shape.b, 0.5), head_color);
            for (set.boxes) |b| if (b.critical) ring(b.shape.center, head_color);
        }
    }
}
