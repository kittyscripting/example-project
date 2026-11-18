//! 17 — Timers and frame delta
//!
//! Three timers driven by `dt` (seconds): an interval that keeps its
//! remainder so it never drifts, a one-shot countdown armed by Space, and a
//! flash that decays with a half-life. `value *= powf(0.5, dt / half_life)`
//! is frame-rate independent; a fixed per-frame factor like `value *= 0.9`
//! is not.

const sdk = @import("sdk");

const Settings = sdk.Settings("Timers", struct {
    enabled: bool = true,
    interval_s: f32 = 2.0,
    decay_half_life: f32 = 0.25,
}, .{
    .enabled = .{ .display_name = "Enabled" },
    .interval_s = .{ .display_name = "Interval (s)", .control = "slider", .min = 0.25, .max = 10.0 },
    .decay_half_life = .{ .display_name = "Flash Half-Life (s)", .control = "slider", .min = 0.05, .max = 1.5 },
});

const ONE_SHOT_S = 1.5;

var elapsed: f32 = 0.0;
var interval_elapsed: f32 = 0.0;
var interval_fires: u32 = 0;
var one_shot_remaining: f32 = 0.0;
var one_shot_arms: u32 = 0;
var flash: f32 = 0.0;

export fn onTick(dt: f32, _: i32) void {
    elapsed += dt;

    interval_elapsed += dt;
    while (interval_elapsed >= Settings.data.interval_s) {
        interval_elapsed -= Settings.data.interval_s;
        interval_fires += 1;
        flash = 1.0;
    }

    one_shot_remaining = @max(0.0, one_shot_remaining - dt);

    if (flash > 0.0) {
        flash *= sdk.powf(0.5, dt / Settings.data.decay_half_life);
        if (flash < 0.01) flash = 0.0;
    }
}

export fn onUIFrame(_: f32, _: i32) void {
    if (!Settings.data.enabled) return;

    // Key edges last one frame; read them here, not in `onTick`.
    if (sdk.isKeyPressed(.space) and one_shot_remaining == 0.0) {
        one_shot_remaining = ONE_SHOT_S;
        one_shot_arms += 1;
    }

    const vp = sdk.render.viewport();
    if (vp.x <= 0.0 or vp.y <= 0.0) return;

    sdk.render.drawFilledRect(12.0, 12.0, 320.0, 130.0, sdk.rgba(0, 0, 0, 175));
    sdk.render.drawTextFmt("elapsed {d:.2}s (tickTime {d:.2}s)", .{ elapsed, sdk.tickTime() }, 22.0, 24.0, 12.0, sdk.rgba(225, 225, 225, 255));
    sdk.render.drawTextFmt("interval {d:.2}s: {d} fires (next in {d:.2}s)", .{
        Settings.data.interval_s,
        interval_fires,
        Settings.data.interval_s - interval_elapsed,
    }, 22.0, 44.0, 12.0, sdk.rgba(190, 220, 255, 255));
    sdk.render.drawTextFmt("one-shot: {d:.2}s left, armed {d}x", .{ one_shot_remaining, one_shot_arms }, 22.0, 64.0, 12.0, sdk.rgba(255, 210, 150, 255));

    bar(86.0, interval_elapsed / Settings.data.interval_s, sdk.rgba(120, 200, 255, 255));
    bar(98.0, one_shot_remaining / ONE_SHOT_S, sdk.rgba(255, 190, 90, 255));

    if (flash > 0.0) {
        const alpha: i32 = @intFromFloat(flash * 90.0);
        sdk.render.drawFilledRect(0.0, 0.0, vp.x, vp.y, sdk.rgba(255, 255, 255, alpha));
    }

    sdk.render.drawText("space arms the one-shot", 22.0, 118.0, 11.0, sdk.rgba(170, 170, 170, 255));
}

fn bar(y: f32, frac: f32, fill: i32) void {
    sdk.render.drawFilledRect(22.0, y, 296.0, 6.0, sdk.rgba(50, 55, 65, 255));
    sdk.render.drawFilledRect(22.0, y, 296.0 * sdk.clampf(frac, 0.0, 1.0), 6.0, fill);
}
