/// One frame of key capture: stores the first pressed key's VK code in
/// `value`; Escape cancels. Returns true when editing ends.
pub fn step(value: *u32) bool { _ = value; return undefined; }

/// Draw the bound key right-aligned in the row, or `...` while `editing`.
/// `0xFFFF_FFFF` shows as Default, `0` as `<none>` (unbound).
pub fn render(x: f32, y: f32, w: f32, h: f32, value: u32, editing: bool, color: i32) void { _ = x; _ = y; _ = w; _ = h; _ = value; _ = editing; _ = color; }
