/// One frame of editing an `0xAARRGGBB` color: Left/Right shift the hue
/// with wraparound, Up/Down change alpha, all with auto-repeat. Enter or
/// Escape ends editing (returns true).
pub fn step(value: *u32) bool { _ = value; return undefined; }

/// Draw a hue bar inset in the row with a cursor at `value`'s hue. No
/// editing outline is drawn; `is_editing` is unused.
pub fn render(x: f32, y: f32, w: f32, h: f32, value: u32, is_editing: bool) void { _ = x; _ = y; _ = w; _ = h; _ = value; _ = is_editing; }
