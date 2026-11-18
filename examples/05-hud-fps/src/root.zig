//! 05 — HUD: frame rate and frame timing
//!
//! A performance panel computed from the `dt` argument and the shared clocks:
//! smoothed FPS and frame time, the worst frame in the last second, the
//! simulation and render clocks, and a bar against a configurable budget.
//! `dt` outside (0, 0.5) s means the process was stalled (window move,
//! suspension) and is ignored.

const std = @import("std");
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

    // Format each line once; the same slices are measured and drawn.
    // Output past 256 bytes is truncated, matching drawTextFmt.
    var title_buf: [256]u8 = undefined;
    var worst_buf: [256]u8 = undefined;
    var clock_buf: [256]u8 = undefined;
    const title = std.fmt.bufPrint(&title_buf, "{d:.0} fps   {d:.2} ms/frame", .{ smooth_fps, smooth_ms }) catch title_buf[0..];
    const worst = std.fmt.bufPrint(&worst_buf, "worst 1s: {d:.2} ms (budget {d:.1})", .{ worst_ms, budget_ms }) catch worst_buf[0..];
    const clock = std.fmt.bufPrint(&clock_buf, "tick {d:.2}s   frame {d:.2}s", .{ sdk.tickTime(), sdk.frameTime() }) catch clock_buf[0..];

    const title_size = 16.0;
    const line_size = 12.0;
    const pad = 10.0;
    const gap = 4.0;
    const bar_h = 6.0;
    const title_m = sdk.render.measureText(title, title_size);
    const worst_m = sdk.render.measureText(worst, line_size);
    const clock_m = sdk.render.measureText(clock, line_size);

    const content_w = @max(title_m.width, @max(worst_m.width, clock_m.width));
    const panel_w = content_w + 2.0 * pad;
    const panel_h = 2.0 * pad + title_m.height + worst_m.height + clock_m.height + bar_h + 3.0 * gap;
    const x = 12.0;
    const y = 12.0;
    const left = x + pad;
    const title_y = y + pad;
    const worst_y = title_y + title_m.height + gap;
    const clock_y = worst_y + worst_m.height + gap;
    const bar_y = clock_y + clock_m.height + gap;

    sdk.render.drawFilledRect(x, y, panel_w, panel_h, sdk.rgba(0, 0, 0, 175));
    sdk.render.drawRect(x, y, panel_w, panel_h, shade, 1.5);

    sdk.render.drawText(title, left, title_y, title_size, sdk.rgba(255, 255, 255, 255));
    sdk.render.drawText(worst, left, worst_y, line_size, sdk.rgba(200, 200, 200, 255));
    sdk.render.drawText(clock, left, clock_y, line_size, sdk.rgba(180, 200, 255, 255));

    const fill = sdk.clampf(smooth_ms / budget_ms, 0.0, 1.0);
    sdk.render.drawFilledRect(left, bar_y, content_w, bar_h, sdk.rgba(60, 60, 60, 255));
    sdk.render.drawFilledRect(left, bar_y, content_w * fill, bar_h, shade);
}
