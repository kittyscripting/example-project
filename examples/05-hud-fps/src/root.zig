//! 05 — HUD: frame rate and frame timing
//!
//! A performance panel computed from the `dt` argument and the shared clocks:
//! smoothed FPS and frame time, the worst frame in the last second, the
//! simulation and render clocks, and a bar against a configurable budget.
//! `dt` outside (0, 0.5) s means the process was stalled (window move,
//! suspension) and is ignored.

const sdk = @import("sdk");

const Settings = sdk.Settings("HUD", struct {
    enabled: bool = true,
    budget_ms: f32 = 16.7,
}, .{
    .enabled = .{ .display_name = "Enabled" },
    .budget_ms = .{ .display_name = "Frame Budget (ms)", .control = "slider", .min = 4.0, .max = 40.0 },
});

const GOOD = sdk.rgba(120, 220, 120, 255);
const BAD = sdk.rgba(255, 90, 90, 255);

var smooth_fps: f32 = 60.0;
var smooth_ms: f32 = 16.0;
var worst_ms: f32 = 0.0;
var worst_window: f32 = 0.0;

export fn onFrame(dt: f32, _: i32) void {
    if (dt <= 0.0 or dt >= 0.5) return;
    const ms = dt * 1000.0;
    smooth_fps = sdk.lerpf(smooth_fps, 1.0 / dt, 0.08);
    smooth_ms = sdk.lerpf(smooth_ms, ms, 0.08);

    // Worst frame over a rolling one-second window.
    worst_ms = @max(worst_ms, ms);
    worst_window += dt;
    if (worst_window >= 1.0) {
        worst_window = 0.0;
        worst_ms = ms;
    }

    if (!Settings.data.enabled) return;
    const vp = sdk.render.viewport();
    if (vp.x <= 0.0 or vp.y <= 0.0) return;

    const budget_ms = Settings.data.budget_ms;
    const over_budget = smooth_ms > budget_ms;
    const shade = if (over_budget) BAD else GOOD;

    sdk.render.drawFilledRect(12.0, 12.0, 250.0, 92.0, sdk.rgba(0, 0, 0, 175));
    sdk.render.drawRect(12.0, 12.0, 250.0, 92.0, shade, 1.5);

    sdk.render.drawTextFmt("{d:.0} fps   {d:.2} ms/frame", .{ smooth_fps, smooth_ms }, 22.0, 22.0, 16.0, sdk.rgba(255, 255, 255, 255));
    sdk.render.drawTextFmt("worst 1s: {d:.2} ms (budget {d:.1})", .{ worst_ms, budget_ms }, 22.0, 44.0, 12.0, sdk.rgba(200, 200, 200, 255));
    sdk.render.drawTextFmt("tick {d:.2}s   frame {d:.2}s", .{ sdk.tickTime(), sdk.frameTime() }, 22.0, 62.0, 12.0, sdk.rgba(180, 200, 255, 255));

    const fill = sdk.clampf(smooth_ms / budget_ms, 0.0, 1.0);
    sdk.render.drawFilledRect(22.0, 84.0, 230.0, 6.0, sdk.rgba(60, 60, 60, 255));
    sdk.render.drawFilledRect(22.0, 84.0, 230.0 * fill, 6.0, shade);
}
