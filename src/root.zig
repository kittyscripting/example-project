//! Starter module: four settings, lifecycle logging, and a top-left overlay
//! showing frame rate and session time.

const sdk = @import("sdk");

/// Each field's type is its storage type and needs a default; fields are
/// shown in declaration order.
const Settings = sdk.Settings("Starter", struct {
    enabled: bool = true,
    accent: u32 = 0xFF5CC8FF,
    text_scale: f32 = 1.0,
    toggle_key: u32 = 0xFFFF_FFFF,
}, .{
    .enabled = .{
        .display_name = "Enabled",
        .description = "Show the starter overlay",
    },
    .accent = .{
        .display_name = "Accent Color",
        .control = "color",
    },
    .text_scale = .{
        .display_name = "Text Scale",
        .control = "slider",
        .min = 0.5,
        .max = 3.0,
    },
    .toggle_key = .{
        .display_name = "Toggle Key",
        .control = "keybind",
    },
});

/// `0xFFFF_FFFF` means the default key; `0` means unbound.
const DEFAULT_TOGGLE_KEY = sdk.Key.backtick;

var visible = true;
var smooth_fps: f32 = 60.0;

/// Settings colors are `0xAARRGGBB`; draw calls take `0xAABBGGRR`.
fn color(argb: u32) i32 {
    return @bitCast(sdk.util.argbToHost(argb));
}

fn togglePressed() bool {
    const bound = Settings.data.toggle_key;
    if (bound == 0) return false;
    const vk: u8 = if (bound == 0xFFFF_FFFF) @intFromEnum(DEFAULT_TOGGLE_KEY) else @truncate(bound);
    return sdk.keyPressed(vk);
}

export fn onLoad() void {
    sdk.info("starter: loaded", .{});
}

export fn onUnload() void {
    sdk.info("starter: unloaded after {d:.1}s", .{sdk.tickTime()});
}

export fn onFrame(dt: f32, _: i32) void {
    if (togglePressed()) visible = !visible;
    if (!Settings.data.enabled or !visible) return;

    // Exponentially smoothed frame rate.
    if (dt > 0.0 and dt < 0.5) {
        smooth_fps = sdk.lerpf(smooth_fps, 1.0 / dt, 0.1);
    }

    const vp = sdk.render.viewport();
    if (vp.x <= 0.0 or vp.y <= 0.0) return;

    const scale = @max(0.5, Settings.data.text_scale);
    const opacity: i32 = 150;
    const panel_w = 236.0 * scale;
    const panel_h = 58.0 * scale;
    const x: f32 = 12.0;
    const y: f32 = 12.0;

    sdk.render.drawFilledRect(x, y, panel_w, panel_h, sdk.rgba(0, 0, 0, opacity));
    sdk.render.drawRect(x, y, panel_w, panel_h, color(Settings.data.accent), 1.0);

    sdk.render.drawTextFmt("fps {d:.0}   frame {d:.1}ms", .{ smooth_fps, dt * 1000.0 }, x + 10.0 * scale, y + 8.0 * scale, 13.0 * scale, color(Settings.data.accent));
    sdk.render.drawTextFmt("session {d:.1}s   actors {d}", .{ sdk.tickTime(), sdk.actors().len }, x + 10.0 * scale, y + 30.0 * scale, 13.0 * scale, sdk.rgba(220, 220, 220, 255));
}
