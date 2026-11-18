/// 8-bit RGBA color.
pub const Color = struct {
    r: u8,
    g: u8,
    b: u8,
    a: u8,
};

/// Convert an `0xAARRGGBB` color to the `0xAABBGGRR` draw-color order.
pub fn argbToHost(color: u32) u32 { _ = color; return undefined; }

/// Whether lowercase ASCII `needle_lower` occurs in `haystack`,
/// case-insensitively.
pub fn containsAsciiLower(haystack: []const u8, needle_lower: []const u8) bool { _ = haystack; _ = needle_lower; return undefined; }

/// Copy as much of `src` as fits in `dst`; returns the byte count.
pub fn copyText(dst: []u8, src: []const u8) usize { _ = dst; _ = src; return undefined; }

pub const math = @import("math.zig");
pub const random = @import("random.zig");
