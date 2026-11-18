//! 06 — Custom crosshair
//!
//! A settings-driven crosshair at the viewport center with three styles
//! (cross, circle, brackets), a gap, a thickness, a color, and an optional
//! center dot. The color setting is `0xAARRGGBB`; draw calls take
//! `0xAABBGGRR`, so it goes through `sdk.util.argbToHost`.

const sdk = @import("sdk");

const Settings = sdk.Settings("Crosshair", struct {
    enabled: bool = true,
    style: u32 = 1,
    size: u32 = 8,
    gap: u32 = 4,
    thickness: f32 = 1.5,
    dot: bool = false,
    color: u32 = 0xFF00FF66,
}, .{
    .enabled = .{ .display_name = "Enabled" },
    .style = .{
        .display_name = "Style",
        .control = "multi",
        .options = .{ "Cross", "Circle", "Brackets" },
    },
    .size = .{ .display_name = "Size (px)", .control = "slider", .min = 2, .max = 40 },
    .gap = .{ .display_name = "Gap (px)", .control = "slider", .min = 0, .max = 20 },
    .thickness = .{ .display_name = "Thickness", .control = "slider", .min = 0.5, .max = 4.0 },
    .dot = .{ .display_name = "Center Dot" },
    .color = .{ .display_name = "Color", .control = "color" },
});

/// Line `(x1, y1)`–`(x2, y2)` as a filled rectangle `thickness` wide; there
/// is no line-width parameter. Only axis-aligned lines are used here.
fn thickLine(x1: f32, y1: f32, x2: f32, y2: f32, thickness: f32, shade: i32) void {
    const min_x = @min(x1, x2) - thickness * 0.5;
    const min_y = @min(y1, y2) - thickness * 0.5;
    sdk.render.drawFilledRect(min_x, min_y, @abs(x2 - x1) + thickness, @abs(y2 - y1) + thickness, shade);
}

export fn onUIFrame(_: f32, _: i32) void {
    if (!Settings.data.enabled) return;

    const vp = sdk.render.viewport();
    if (vp.x <= 0.0 or vp.y <= 0.0) return;

    const cx = vp.x * 0.5;
    const cy = vp.y * 0.5;
    const size: f32 = @floatFromInt(Settings.data.size);
    const gap: f32 = @floatFromInt(Settings.data.gap);
    const thickness = Settings.data.thickness;
    const shade: i32 = @bitCast(sdk.util.argbToHost(Settings.data.color));

    switch (Settings.data.style) {
        0 => {
            thickLine(cx, cy - gap - size, cx, cy - gap, thickness, shade);
            thickLine(cx, cy + gap, cx, cy + gap + size, thickness, shade);
            thickLine(cx - gap - size, cy, cx - gap, cy, thickness, shade);
            thickLine(cx + gap, cy, cx + gap + size, cy, thickness, shade);
        },
        1 => {
            sdk.render.drawCircle(cx, cy, size + gap, shade, false);
            sdk.render.drawLine(cx - size * 0.5, cy, cx + size * 0.5, cy, shade);
            sdk.render.drawLine(cx, cy - size * 0.5, cx, cy + size * 0.5, shade);
        },
        else => {
            const r = size + gap;
            const arm = size * 0.6;
            sdk.render.drawLine(cx - r, cy - r, cx - r + arm, cy - r, shade);
            sdk.render.drawLine(cx - r, cy - r, cx - r, cy - r + arm, shade);
            sdk.render.drawLine(cx + r, cy - r, cx + r - arm, cy - r, shade);
            sdk.render.drawLine(cx + r, cy - r, cx + r, cy - r + arm, shade);
            sdk.render.drawLine(cx - r, cy + r, cx - r + arm, cy + r, shade);
            sdk.render.drawLine(cx - r, cy + r, cx - r, cy + r - arm, shade);
            sdk.render.drawLine(cx + r, cy + r, cx + r - arm, cy + r, shade);
            sdk.render.drawLine(cx + r, cy + r, cx + r, cy + r - arm, shade);
        },
    }

    if (Settings.data.dot) {
        sdk.render.drawCircle(cx, cy, @max(1.0, thickness), shade, true);
    }
}
