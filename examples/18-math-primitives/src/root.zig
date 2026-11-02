//! 18 — Math: vectors, quaternions, matrices
//!
//! A sampler of the `sdk` math types: `Vec2`/`Vec3`/`Vec4`, `Quat`, `Mat4`,
//! and the `sdk.util.math` angle helpers. All values are `f32` and methods
//! return new values instead of mutating. World positions are meters; angles
//! are radians unless a helper says otherwise. `Mat4` is column-major, so
//! `m[col * 4 + row]`.

const sdk = @import("sdk");

const Settings = sdk.Settings("Math Tour", struct {
    enabled: bool = true,
    spin_speed: f32 = 1.0,
}, .{
    .enabled = .{ .display_name = "Enabled" },
    .spin_speed = .{ .display_name = "Spin Speed", .control = "slider", .min = 0.0, .max = 4.0 },
});

const TEXT = sdk.rgba(225, 225, 225, 255);
const FORWARD = sdk.Vec3.init(0.0, 0.0, 1.0);

fn row(y: f32, comptime fmt: []const u8, args: anytype) void {
    sdk.render.drawTextFmt(fmt, args, 20.0, y, 12.0, TEXT);
}

export fn onUIFrame(_: f32, _: i32) void {
    if (!Settings.data.enabled) return;

    const vp = sdk.render.viewport();
    if (vp.x <= 0.0 or vp.y <= 0.0) return;

    const a = sdk.Vec3.init(1.0, 2.0, 3.0);
    const b = sdk.Vec3.init(-1.0, 0.5, 4.0);
    const sum = a.add(b);
    const cross = a.cross(b);

    const spin = sdk.frameTime() * Settings.data.spin_speed;
    const rotation = sdk.Quat.fromEuler(0.35, spin, 0.0);
    const forward = rotation.rotateVec3(FORWARD);
    const halfway = sdk.Quat.slerp(sdk.Quat.identity(), rotation, 0.5).rotateVec3(FORWARD);
    const angle_deg = sdk.Quat.angleBetween(sdk.Quat.identity(), rotation) * sdk.util.math.rad_to_deg;

    const axis_dir = sdk.Vec3.init(0.3, 0.9, -0.2).normalized();
    const round_trip = sdk.quatToDirection(sdk.quatFromDirection(axis_dir));

    const model = sdk.Mat4.translation(1.0, 2.0, 3.0).mul(sdk.Mat4.scaling(2.0, 2.0, 2.0));
    const point = sdk.Mat4.transformPoint(model, sdk.Vec3.init(0.5, 0.5, 0.5));
    const spun_dir = sdk.Mat4.transformDir(sdk.Mat4.rotationZ(spin), sdk.Vec3.init(1.0, 0.0, 0.0));

    const heading = sdk.util.math.yawPitch(forward);
    const rebuilt = sdk.util.math.fromYawPitch(heading.x, heading.y);

    sdk.render.drawFilledRect(12.0, 12.0, 430.0, 180.0, sdk.rgba(0, 0, 0, 175));

    var y: f32 = 24.0;
    row(y, "a + b        = ({d:.1}, {d:.1}, {d:.1})", .{ sum.x, sum.y, sum.z });
    y += 16.0;
    row(y, "a x b        = ({d:.2}, {d:.2}, {d:.2})", .{ cross.x, cross.y, cross.z });
    y += 16.0;
    row(y, "a . b        = {d:.3}    |a-b| = {d:.3}", .{ a.dot(b), a.dist(b) });
    y += 16.0;
    row(y, "q.rotateVec3 = ({d:.2}, {d:.2}, {d:.2})", .{ forward.x, forward.y, forward.z });
    y += 16.0;
    row(y, "slerp(t=0.5) = ({d:.2}, {d:.2}, {d:.2})", .{ halfway.x, halfway.y, halfway.z });
    y += 16.0;
    row(y, "angle(identity,q) = {d:.1} deg", .{angle_deg});
    y += 16.0;
    row(y, "dir round trip err = {d:.4} deg", .{sdk.util.math.angleDeg(axis_dir, round_trip)});
    y += 16.0;
    row(y, "mat4 * (0.5,.5,.5) = ({d:.1}, {d:.1}, {d:.1})", .{ point.x, point.y, point.z });
    y += 16.0;
    row(y, "rotZ dir at spin   = ({d:.2}, {d:.2}, {d:.2})", .{ spun_dir.x, spun_dir.y, spun_dir.z });
    y += 16.0;
    row(y, "yaw {d:.1}  pitch {d:.1}  rebuild err {d:.4} deg", .{
        heading.x * sdk.util.math.rad_to_deg,
        heading.y * sdk.util.math.rad_to_deg,
        sdk.util.math.angleDeg(forward, rebuilt),
    });

    // Compass: yaw is atan2(z, x), so x = cos(yaw) and screen y = -sin(yaw).
    const center_x = vp.x * 0.5;
    const center_y = 260.0;
    const radius = 80.0;
    sdk.render.drawCircle(center_x, center_y, radius, sdk.rgba(120, 200, 255, 170), false);

    const tip = sdk.Vec2.init(
        center_x + sdk.cosf(heading.x) * radius * 0.85,
        center_y - sdk.sinf(heading.x) * radius * 0.85,
    );
    sdk.render.drawLine(center_x, center_y, tip.x, tip.y, sdk.rgba(255, 210, 90, 255));
    sdk.render.drawCircle(tip.x, tip.y, 5.0, sdk.rgba(255, 210, 90, 255), true);
    sdk.render.drawTextCenteredFmt("{d:.0} deg", .{heading.x * sdk.util.math.rad_to_deg}, center_x, center_y + radius + 10.0, 13.0, sdk.rgba(230, 230, 230, 255));
}
