//! 02 — Settings: every field type and control
//!
//! One settings category covering all supported value types (`bool`, `i32`,
//! `u32`, `i64`, `f32`, `f64`) and every control: checkbox, sliders, a
//! one-of-many picker, a key bind, and a color. The live values are drawn
//! on screen.

const sdk = @import("sdk");

/// Field declaration order is the display order. Each field's Zig type
/// decides how it is stored; a constraint entry (`.display_name`,
/// `.description`, `.control`, `.min`, `.max`, `.options`) is optional.
const Settings = sdk.Settings("Settings Tour", struct {
    enabled: bool = true,
    int_value: i32 = -3,
    uint_value: u32 = 7,
    big_value: i64 = 1_000_000,
    ratio: f32 = 0.5,
    precise_ratio: f64 = 0.25,
    quality: u32 = 2,
    opacity: f32 = 0.8,
    mode: u32 = 1,
    toggle_key: u32 = 0xFFFF_FFFF,
    tint: u32 = 0xFF66CCFF,
}, .{
    .enabled = .{ .display_name = "Enabled", .description = "Show the panel" },
    // Numeric fields: `.min`/`.max` plus `.control = "slider"` make a slider.
    .int_value = .{ .display_name = "Signed Count", .control = "slider", .min = -100, .max = 100 },
    .uint_value = .{ .display_name = "Unsigned Count", .control = "slider", .min = 0, .max = 255 },
    .big_value = .{ .display_name = "Big Counter" },
    .ratio = .{ .display_name = "Ratio", .control = "slider", .min = 0.0, .max = 1.0 },
    .precise_ratio = .{ .display_name = "Precise Ratio", .control = "slider", .min = 0.0, .max = 1.0 },
    .quality = .{ .display_name = "Quality", .control = "slider", .min = 0, .max = 4 },
    .opacity = .{ .display_name = "Opacity", .control = "slider", .min = 0.0, .max = 1.0 },
    // u32 + `.options`: a `< value >` picker; the value is the option index.
    .mode = .{ .display_name = "Mode", .control = "multi", .options = .{ "Off", "Basic", "Full" } },
    // u32 + keybind: a virtual-key code. `0xFFFF_FFFF` = default key,
    // `0` = unbound.
    .toggle_key = .{ .display_name = "Toggle Key", .control = "keybind" },
    // u32 + color: an `0xAARRGGBB` value with a hue/alpha picker.
    .tint = .{ .display_name = "Tint", .control = "color" },
});

const MODES = [_][]const u8{ "Off", "Basic", "Full" };

const TEXT = sdk.rgba(225, 225, 225, 255);

/// Draw calls take `0xAABBGGRR`, settings colors are `0xAARRGGBB`.
fn color(argb: u32) i32 {
    return @bitCast(sdk.util.argbToHost(argb));
}

fn row(y: f32, comptime fmt: []const u8, args: anytype) void {
    sdk.render.drawTextFmt(fmt, args, 20.0, y, 12.0, TEXT);
}

export fn onUIFrame(_: f32, _: i32) void {
    if (!Settings.data.enabled) return;

    const vp = sdk.render.viewport();
    if (vp.x <= 0.0 or vp.y <= 0.0) return;

    const line_h = 16.0;
    const panel_w = 340.0;
    const panel_h = line_h * 12.0 + 16.0;
    const tint = color(Settings.data.tint);
    sdk.render.drawFilledRect(12.0, 12.0, panel_w, panel_h, sdk.rgba(0, 0, 0, 170));
    sdk.render.drawRect(12.0, 12.0, panel_w, panel_h, tint, 1.0);
    sdk.render.drawText("Settings Tour - live values", 20.0, 22.0, 13.0, tint);

    const mode = MODES[@min(@as(usize, Settings.data.mode), MODES.len - 1)];
    var y: f32 = 44.0;
    row(y, "enabled (bool): {any}", .{Settings.data.enabled});
    y += line_h;
    row(y, "int_value (i32): {d}", .{Settings.data.int_value});
    y += line_h;
    row(y, "uint_value (u32): {d}", .{Settings.data.uint_value});
    y += line_h;
    row(y, "big_value (i64): {d}", .{Settings.data.big_value});
    y += line_h;
    row(y, "ratio (f32): {d:.3}", .{Settings.data.ratio});
    y += line_h;
    row(y, "precise_ratio (f64): {d:.3}", .{Settings.data.precise_ratio});
    y += line_h;
    row(y, "quality (u32): {d}", .{Settings.data.quality});
    y += line_h;
    row(y, "opacity (f32): {d:.2}", .{Settings.data.opacity});
    y += line_h;
    row(y, "mode (multi): {s}", .{mode});
    y += line_h;
    row(y, "toggle_key (keybind): 0x{X:0>8}", .{Settings.data.toggle_key});
    y += line_h;
    row(y, "tint (color): 0x{X:0>8}", .{Settings.data.tint});
}
