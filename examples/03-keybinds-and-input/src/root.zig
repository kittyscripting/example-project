//! 03 — Key binds and input state
//!
//! A settings-driven toggle key plus a read-only readout of keyboard, mouse,
//! and action-button state. A keybind setting stores a virtual-key code:
//! `0xFFFF_FFFF` means the default key, `0` means unbound, anything else is
//! the captured code. Action buttons are `false` without a local actor.

const sdk = @import("sdk");

const Settings = sdk.Settings("Input Tour", struct {
    enabled: bool = true,
    toggle_key: u32 = 0xFFFF_FFFF,
    extra_key: u32 = 0xFFFF_FFFF,
}, .{
    .enabled = .{ .display_name = "Enabled" },
    .toggle_key = .{ .display_name = "Toggle Key", .control = "keybind" },
    .extra_key = .{
        .display_name = "Extra Key",
        .control = "keybind",
        .description = "Falls back to the melee button when unset",
    },
});

const TEXT = sdk.rgba(225, 225, 225, 255);

var visible = true;
var last_press_code: u8 = 0;

fn boundVk(setting: u32, fallback: sdk.Key) u8 {
    if (setting == 0) return 0;
    return if (setting == 0xFFFF_FFFF) @intFromEnum(fallback) else @truncate(setting);
}

fn pressed(local: ?*sdk.LocalActor, button: sdk.GameButton) bool {
    return if (local) |l| l.isPressed(button) else false;
}

fn row(y: f32, comptime fmt: []const u8, args: anytype) void {
    sdk.render.drawTextFmt(fmt, args, 20.0, y, 12.0, TEXT);
}

/// Key edges last one frame; read them here, not in `onTick`.
export fn onUIFrame(_: f32, _: i32) void {
    const vk = boundVk(Settings.data.toggle_key, .backtick);
    if (vk != 0 and sdk.keyPressed(vk)) visible = !visible;
    const code = sdk.firstKeyPressed();
    if (code != 0) last_press_code = code;

    if (!Settings.data.enabled or !visible) return;

    const vp = sdk.render.viewport();
    if (vp.x <= 0.0 or vp.y <= 0.0) return;

    const local = sdk.localActor();
    const extra = if (local) |l| sdk.isKeyOrGameButtonDown(l, Settings.data.extra_key, .melee) else false;
    const name = sdk.input.keyName(last_press_code) orelse "-";

    sdk.render.drawFilledRect(12.0, 12.0, 400.0, 16.0 * 11.0 + 16.0, sdk.rgba(0, 0, 0, 170));
    var y: f32 = 24.0;
    row(y, "modifiers: shift={any} ctrl={any} alt={any}", .{ sdk.isKeyDown(.shift), sdk.isKeyDown(.ctrl), sdk.isKeyDown(.alt) });
    y += 16.0;
    row(y, "F1 pressed={any}   space pressed={any}", .{ sdk.isKeyPressed(.f1), sdk.isKeyPressed(.space) });
    y += 16.0;
    row(y, "last key pressed: {s} (0x{X:0>2})", .{ name, last_press_code });
    y += 16.0;
    row(y, "first key down: 0x{X:0>2}", .{sdk.firstKeyDown()});
    y += 16.0;
    row(y, "mouse held: l={any} r={any} m={any}", .{
        sdk.isMouseButtonPressed(.left),
        sdk.isMouseButtonPressed(.right),
        sdk.isMouseButtonPressed(.middle),
    });
    y += 16.0;
    row(y, "mouse delta: {d:.1}, {d:.1}", .{ sdk.mouseDeltaX(), sdk.mouseDeltaY() });
    y += 16.0;
    row(y, "mouse position: {d:.0}, {d:.0}", .{ sdk.mouseX(), sdk.mouseY() });
    y += 16.0;
    row(y, "buttons: fire={any} alt={any} ability={any} ult={any} jump={any}", .{
        pressed(local, .primary_fire),
        pressed(local, .secondary_fire),
        pressed(local, .ability1),
        pressed(local, .ultimate),
        pressed(local, .jump),
    });
    y += 16.0;
    row(y, "extra key (or melee) held: {any}", .{extra});
    y += 16.0;
    row(y, "toggle key binding: 0x{X:0>8}", .{Settings.data.toggle_key});
}
