/// Lines of `text` inside a `max_width` by `max_height` box at `size`.
pub const Iterator = struct {
    /// Next line without its newline: borrows `text`, or `scratch` when `...` is used.
    /// A 256-byte `scratch` gives the longest line; null after the last that fits.
    pub fn next(self: *Iterator, scratch: []u8) ?[]const u8 { _ = self; _ = scratch; return undefined; }
};

/// Wrap `text` into `max_width` by `max_height` at `size`, ending in `...` when text is dropped.
pub fn wrap(text: []const u8, size: f32, max_width: f32, max_height: f32) Iterator { _ = text; _ = size; _ = max_width; _ = max_height; return undefined; }

/// Height `text` needs at `max_width`; 0 for empty text, null when it cannot fit.
pub fn heightForWidth(text: []const u8, size: f32, max_width: f32) ?f32 { _ = text; _ = size; _ = max_width; return undefined; }

/// Narrowest width fitting `text` in `max_height`; null when it cannot fit.
pub fn widthForHeight(text: []const u8, size: f32, max_height: f32) ?f32 { _ = text; _ = size; _ = max_height; return undefined; }
