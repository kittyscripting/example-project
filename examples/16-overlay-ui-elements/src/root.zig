//! 16 — In-overlay UI elements
//!
//! A small panel built from the shared `sdk.render.elements.basic` controls (boolean,
//! slider, one-of-many, key bind, color). Each control's `step` consumes input
//! for one frame and returns true when editing ends; `render` draws it into a
//! rectangle in logical pixels. F7 shows and hides the panel, Up/Down move
//! the selection, Enter starts and finishes editing.

const sdk = @import("sdk");

const POSITIONS = [_][]const u8{ "top-left", "top-right", "bottom-left", "bottom-right" };
const LABELS = [_][]const u8{ "Enabled", "Size", "Count", "Position", "Toggle Key", "Tint" };

/// Panel state (module-local, not persisted).
const Values = struct {
    enabled: bool = true,
    size: f32 = 1.2,
    count: u32 = 12,
    position: u32 = 1,
    toggle_key: u32 = 0xFFFF_FFFF,
    tint: u32 = 0xFF66CCFF,
};

var values: Values = .{};
var selected: usize = 0;
var editing: bool = false;
var visible: bool = true;

export fn onUIFrame(_: f32, _: i32) void {
    if (sdk.isKeyPressed(.f7)) visible = !visible;
    if (!visible) return;

    if (editing) {
        const done = switch (selected) {
            0 => sdk.render.elements.basic.boolean.step(&values.enabled),
            1 => sdk.render.elements.basic.slider.stepF32(&values.size, 0.5, 3.0),
            2 => sdk.render.elements.basic.slider.step(&values.count, 1, 64),
            3 => sdk.render.elements.basic.multi.step(&values.position, @intCast(POSITIONS.len)),
            4 => sdk.render.elements.basic.keybind.step(&values.toggle_key),
            else => sdk.render.elements.basic.colorpicker.step(&values.tint),
        };
        if (done) editing = false;
    } else {
        if (sdk.render.elements.basic.input.pressedRepeat(@intFromEnum(sdk.Key.up), 18, 3)) {
            selected = if (selected == 0) LABELS.len - 1 else selected - 1;
        }
        if (sdk.render.elements.basic.input.pressedRepeat(@intFromEnum(sdk.Key.down), 18, 3)) {
            selected = (selected + 1) % LABELS.len;
        }
        if (sdk.render.elements.basic.input.pressed(@intFromEnum(sdk.Key.enter))) editing = true;
    }

    const panel_x = 20.0;
    const panel_y = 20.0;
    const row_h = 22.0;
    const panel_w = 330.0;
    const panel_h = row_h * @as(f32, @floatFromInt(LABELS.len)) + 44.0;
    const accent = sdk.rgba(120, 200, 255, 255);

    sdk.render.drawFilledRect(panel_x, panel_y, panel_w, panel_h, sdk.rgba(10, 10, 14, 195));
    sdk.render.drawRect(panel_x, panel_y, panel_w, panel_h, sdk.rgba(120, 160, 220, 200), 1.0);
    sdk.render.drawText(
        if (editing) "elements demo: editing (enter / escape)" else "elements demo: up/down, enter edits",
        panel_x + 10.0,
        panel_y + 8.0,
        12.0,
        sdk.rgba(220, 220, 220, 255),
    );

    for (LABELS, 0..) |label, i| {
        const y = panel_y + 30.0 + row_h * @as(f32, @floatFromInt(i));
        const is_selected = i == selected;
        if (is_selected) {
            sdk.render.drawFilledRect(panel_x + 4.0, y - 2.0, panel_w - 8.0, row_h, sdk.rgba(70, 110, 180, 140));
        }
        const label_color = if (is_selected) sdk.rgba(255, 255, 255, 255) else sdk.rgba(200, 200, 200, 255);
        sdk.render.drawText(label, panel_x + 12.0, y + 4.0, 12.0, label_color);

        const control_x = panel_x + 150.0;
        const control_w = panel_w - 162.0;
        const control_h = row_h - 4.0;
        switch (i) {
            0 => sdk.render.elements.basic.boolean.render(control_x, y, control_w, control_h, values.enabled, label_color),
            1 => sdk.render.elements.basic.slider.renderF32(control_x, y, control_w, control_h, values.size, 0.5, 3.0, accent, sdk.rgba(50, 60, 80, 255)),
            2 => sdk.render.elements.basic.slider.render(control_x, y, control_w, control_h, values.count, 1, 64, accent, sdk.rgba(50, 60, 80, 255)),
            3 => sdk.render.elements.basic.multi.render(control_x, y, control_w, control_h, values.position, POSITIONS[0..], label_color),
            4 => sdk.render.elements.basic.keybind.render(control_x, y, control_w, control_h, values.toggle_key, editing and is_selected, label_color),
            else => sdk.render.elements.basic.colorpicker.render(control_x, y, control_w, control_h, values.tint, editing and is_selected),
        }
    }

    sdk.render.drawTextFmt("size {d:.2}   count {d}   tint 0x{X:0>8}", .{ values.size, values.count, values.tint }, panel_x + 12.0, panel_y + panel_h - 14.0, 11.0, sdk.rgba(170, 170, 170, 255));
}
