/// One frame of editing an index into `option_count` options: Left/Right
/// move with wraparound, Enter or Escape ends editing (returns true).
pub fn step(value: *u32, option_count: u32) bool { _ = value; _ = option_count; return undefined; }

/// Draw `< label >` for `options[value]` in the row, truncating the label
/// to fit. Out-of-range values show the last option.
pub fn render(x: f32, y: f32, w: f32, h: f32, value: u32, options: []const []const u8, color: i32) void { _ = x; _ = y; _ = w; _ = h; _ = value; _ = options; _ = color; }
