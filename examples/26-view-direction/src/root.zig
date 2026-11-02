//! 26 — View direction
//!
//! `local.last_view_direction` is the view as last read. `local.viewDirection()`
//! adds this tick's mouse rotation: it is where the shot sent this tick goes,
//! so test hits against it. A view written with `setViewDir` still gets the
//! player's mouse rotation added on top; plan it from `last_view_direction`
//! and test it with `sdk.input.withMouseRotation`. To replace the player's
//! rotation instead, zero the sensitivity and write the view yourself.

const sdk = @import("sdk");
const math = sdk.util.math;
const Vec3 = sdk.Vec3;

const Settings = sdk.Settings("View Direction", struct {
    enabled: bool = true,
    nudge_key: u32 = 0,
    nudge_strength: f32 = 0.1,
    slow_key: u32 = 0,
    slow_scale: f32 = 0.5,
}, .{
    .enabled = .{ .display_name = "Enabled" },
    .nudge_key = .{
        .display_name = "Nudge Key",
        .control = "keybind",
        .description = "Hold to pull the view toward the nearest enemy; your mouse still moves it",
    },
    .nudge_strength = .{ .display_name = "Nudge Strength", .control = "slider", .min = 0.0, .max = 1.0 },
    .slow_key = .{
        .display_name = "Slow Mouse Key",
        .control = "keybind",
        .description = "Hold to scale your mouse rotation",
    },
    .slow_scale = .{ .display_name = "Slow Scale", .control = "slider", .min = 0.0, .max = 1.0 },
});

const TEXT = sdk.rgba(225, 225, 225, 255);
const LAST = sdk.rgba(120, 200, 255, 255);
const NEXT = sdk.rgba(255, 190, 90, 255);

const Mode = enum { watch, nudge, slow };

var mode: Mode = .watch;
var eye = Vec3.init(0.0, 0.0, 0.0);
var last_dir = Vec3.init(0.0, 0.0, 0.0);
var next_dir = Vec3.init(0.0, 0.0, 0.0);
/// Enemy id on each ray this tick; 0 for none.
var last_hit: i32 = 0;
var next_hit: i32 = 0;
var written_hit: i32 = 0;
var slow_held = false;

fn enemyOnRay(from: Vec3, dir: Vec3) i32 {
    for (sdk.actors()) |*actor| {
        if (actor.team != .enemy) continue;
        if (sdk.helpers.hitboxes.rayHitsHitboxes(actor, from, dir, Vec3.init(0.0, 0.0, 0.0), 1.0, false)) return actor.id;
    }
    return 0;
}

/// Unit direction to the enemy hitbox point closest to `view`.
fn nearestEnemyDir(from: Vec3, view: Vec3) ?Vec3 {
    var best: ?Vec3 = null;
    var best_angle: f32 = 180.0;
    for (sdk.actors()) |*actor| {
        if (actor.team != .enemy) continue;
        const point = sdk.helpers.hitboxes.nearestHitboxPoint(actor, from, view, false) orelse continue;
        const dir = point.sub(from).normalized();
        const angle = math.angleDeg(view, dir);
        if (angle < best_angle) {
            best_angle = angle;
            best = dir;
        }
    }
    return best;
}

fn releaseSlow() void {
    if (slow_held) sdk.input.resetSensitivity();
    slow_held = false;
}

export fn onTick(_: f32, _: i32) void {
    mode = .watch;
    written_hit = 0;
    const local = sdk.localActor() orelse return releaseSlow();
    const avatar = local.avatar orelse return releaseSlow();
    if (!Settings.data.enabled) return releaseSlow();

    eye = sdk.camera.position() orelse avatar.transform.position;
    last_dir = local.last_view_direction;
    next_dir = local.viewDirection();
    last_hit = enemyOnRay(eye, last_dir);
    next_hit = enemyOnRay(eye, next_dir);

    // Replace the player's rotation: with the sensitivity at zero the engine
    // adds nothing, so the written view is the view sent.
    if (sdk.isKeyOrGameButtonDown(local, Settings.data.slow_key, .melee)) {
        sdk.input.setSensitivity(0.0);
        slow_held = true;
        mode = .slow;
        const mouse = sdk.input.mouseViewDelta() orelse sdk.Vec2.init(0.0, 0.0);
        const angles = math.yawPitch(last_dir);
        const written = math.fromYawPitch(
            math.normalizeRadians(angles.x + mouse.x * Settings.data.slow_scale),
            math.clampPitch(angles.y + mouse.y * Settings.data.slow_scale),
        );
        local.setViewDir(written);
        written_hit = enemyOnRay(eye, written);
        return;
    }
    releaseSlow();

    // Write on top of the player's rotation: the engine adds this tick's
    // mouse rotation to the written view.
    if (sdk.isKeyOrGameButtonDown(local, Settings.data.nudge_key, .melee)) {
        mode = .nudge;
        const target = nearestEnemyDir(eye, next_dir) orelse return;
        const written = last_dir.add(target.sub(last_dir).scale(Settings.data.nudge_strength)).normalized();
        local.setViewDir(written);
        written_hit = enemyOnRay(eye, sdk.input.withMouseRotation(written));
    }
}

fn marker(dir: Vec3, color: i32) void {
    if (!sdk.camera.active() or dir.length() == 0.0) return;
    const s = sdk.camera.w2s(eye.add(dir.scale(10.0))) orelse return;
    sdk.render.drawCircle(s.x, s.y, 4.0, color, true);
}

fn row(y: f32, comptime fmt: []const u8, args: anytype, color: i32) void {
    sdk.render.drawTextFmt(fmt, args, 20.0, y, 12.0, color);
}

export fn onFrame(_: f32, _: i32) void {
    if (!Settings.data.enabled or sdk.localActor() == null) return;

    marker(last_dir, LAST);
    marker(next_dir, NEXT);

    sdk.render.drawFilledRect(12.0, 12.0, 340.0, 16.0 * 5.0 + 16.0, sdk.rgba(0, 0, 0, 170));
    var y: f32 = 24.0;
    row(y, "mode: {s}", .{@tagName(mode)}, TEXT);
    y += 16.0;
    row(y, "last_view_direction on enemy: {d}", .{last_hit}, LAST);
    y += 16.0;
    row(y, "viewDirection() on enemy: {d}", .{next_hit}, NEXT);
    y += 16.0;
    row(y, "written view on enemy: {d}", .{written_hit}, TEXT);
    y += 16.0;
    if (sdk.input.mouseViewDelta()) |m| {
        row(y, "mouse this tick: yaw {d:.2} pitch {d:.2} deg", .{ m.x * math.rad_to_deg, m.y * math.rad_to_deg }, TEXT);
    } else {
        row(y, "mouse this tick: not published", .{}, TEXT);
    }
}
