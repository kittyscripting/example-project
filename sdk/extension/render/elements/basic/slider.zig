/// One frame of editing an integer in `[min, max]`: Left/Right step by a
/// 64th of the range with auto-repeat, or by 1 per press with Shift held.
/// Enter or Escape ends editing (returns true).
pub fn step(value: *u32, min: u32, max: u32) bool { _ = value; _ = min; _ = max; return undefined; }

/// Float variant of `step`; Shift steps by exactly 1.
pub fn stepF32(value: *f32, min: f32, max: f32) bool { _ = value; _ = min; _ = max; return undefined; }

/// Draw a `bg` track filled with `fg` up to `value`'s position in
/// `[min, max]`. Value text is drawn separately.
pub fn render(x: f32, y: f32, w: f32, h: f32, value: u32, min: u32, max: u32, fg: i32, bg: i32) void { _ = x; _ = y; _ = w; _ = h; _ = value; _ = min; _ = max; _ = fg; _ = bg; }

/// Float variant of `render`.
pub fn renderF32(x: f32, y: f32, w: f32, h: f32, value: f32, min: f32, max: f32, fg: i32, bg: i32) void { _ = x; _ = y; _ = w; _ = h; _ = value; _ = min; _ = max; _ = fg; _ = bg; }
