//! 14 — Target selection
//!
//! The SDK target tracker picks one enemy inside a field-of-view cone,
//! with switch debounce and an optional held lock. Draws the chosen aim point,
//! the raw aim point, and the screen-space lead between them for the first enabled
//! gun's projectile. Tracker state lives at module scope; the returned
//! actor borrows the current scene snapshot.

const sdk = @import("sdk");
const targeting = sdk.helpers.target;

const Settings = sdk.Settings("Target Selection", struct {
    enabled: bool = true,
    fov: f32 = 25.0,
    max_range: f32 = 80.0,
    lock_target: bool = false,
    hitbox: u32 = 1,
    score: u32 = 0,
    swap_delay_ms: f32 = 150.0,
    use_prediction: bool = true,
}, .{
    .enabled = .{ .display_name = "Enabled" },
    .fov = .{ .display_name = "FOV (deg)", .control = "slider", .min = 1.0, .max = 170.0 },
    .max_range = .{ .display_name = "Max Range (m)", .control = "slider", .min = 0.0, .max = 200.0 },
    .lock_target = .{ .display_name = "Hold Lock" },
    .hitbox = .{
        .display_name = "aim Point",
        .control = "multi",
        .options = .{ "defined", "head", "body", "nearest", "origin" },
    },
    .score = .{
        .display_name = "Score",
        .control = "multi",
        .options = .{ "fitts", "crosshair" },
    },
    .swap_delay_ms = .{ .display_name = "Swap Delay (ms)", .control = "slider", .min = 0.0, .max = 600.0 },
    .use_prediction = .{ .display_name = "Lead Projectiles" },
});

const PICKS = [_]targeting.HitboxPick{ .defined, .head, .body, .nearest, .origin };
const SCORES = [_]targeting.TargetScore{ .fitts, .crosshair };

/// Lock, grace, and debounce timers.
var tracker: targeting.TargetTracker = .{};

export fn onFrame(_: f32, _: i32) void {
    if (!Settings.data.enabled or !sdk.camera.active()) return;

    const local = sdk.localActor() orelse return;
    const avatar = local.avatar orelse return;
    const vp = sdk.render.viewport();
    if (vp.x <= 0.0 or vp.y <= 0.0) return;

    const ctx = targeting.TargetCtx{
        .fov_deg = Settings.data.fov,
        .swap_delay_ms = Settings.data.swap_delay_ms,
        .lock_target = Settings.data.lock_target,
        .hitbox = PICKS[@min(@as(usize, Settings.data.hitbox), PICKS.len - 1)],
        .score = SCORES[@min(@as(usize, Settings.data.score), SCORES.len - 1)],
        .max_range = Settings.data.max_range, // 0 = unlimited
        .effect_target = .enemy,
    };

    // `now_ms` drives the lock grace and swap debounce timers.
    const target = tracker.step(sdk.actors(), local, ctx, sdk.tickTime() * 1000.0);
    if (!target.is_valid) {
        sdk.render.drawTextCentered("no target", vp.x * 0.5, vp.y * 0.5 + 40.0, 12.0, sdk.rgba(200, 200, 200, 200));
        return;
    }

    var speed: f32 = 0.0;
    var gravity: f32 = 0.0;
    var launch_angle: f32 = 0.0;
    if (local.firstEnabledGun()) |gun| {
        speed = gun.projectile_speed;
        gravity = gun.projectile_gravity;
        launch_angle = gun.projectile_launch_angle;
    }
    const lead = Settings.data.use_prediction and speed > 0.0;
    const raw = target.aim_point;
    const led = if (lead) sdk.prediction.refine(target.actor, raw, speed, gravity, launch_angle) else raw;

    const raw_screen = sdk.camera.w2s(raw);
    if (raw_screen) |p| sdk.render.drawCircle(p.x, p.y, 4.0, sdk.rgba(120, 200, 255, 220), true);

    const p = sdk.camera.w2s(led) orelse return;
    const shade = sdk.rgba(90, 255, 130, 235);
    sdk.render.drawCircle(p.x, p.y, 9.0, shade, false);
    sdk.render.drawLine(p.x - 12.0, p.y, p.x + 12.0, p.y, shade);
    sdk.render.drawLine(p.x, p.y - 12.0, p.x, p.y + 12.0, shade);
    if (lead) {
        if (raw_screen) |r| sdk.render.drawLine(r.x, r.y, p.x, p.y, sdk.rgba(255, 220, 120, 220));
    }

    sdk.render.drawTextFmt("id {d}  {d:.0}m", .{
        target.actor.id,
        avatar.transform.position.dist(target.actor.transform.position),
    }, p.x + 14.0, p.y + 8.0, 11.0, sdk.rgba(230, 230, 230, 255));
}
