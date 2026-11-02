const runtime = @import("runtime");
const Vec2 = runtime.Vec2;
const Vec3 = runtime.Vec3;
const Quat = runtime.Quat;
pub const elements = @import("render/elements/root.zig");

/// Render surface size in logical pixels; zero until the first frame.
pub fn viewport() Vec2 { return undefined; }

/// UI scale: viewport height over 1080, rounded to a multiple of 0.5 and at
/// least 0.5. 1 before the first frame.
pub fn scale() f32 { return undefined; }

/// Top-left of the window in screen pixels.
pub fn windowPos() Vec2 { return undefined; }

pub fn windowSize() Vec2 { return undefined; }

/// Top-left of the client area in screen pixels; differs from `windowPos`
/// by the border and titlebar in windowed mode.
pub fn clientPos() Vec2 { return undefined; }

pub fn clientSize() Vec2 { return undefined; }

/// 0 for borderless and fullscreen windows.
pub fn titlebarHeight() f32 { return undefined; }

/// Create a texture from tightly packed BGRA8 pixels (`w * h * 4` bytes).
/// The pixels are copied, so `bgra` may be reused immediately. Returns the
/// texture id, or 0 when the size does not match or the upload fails. The
/// texture lives until `freeTexture`.
pub fn uploadBitmap(bgra: []const u8, w: u32, h: u32) u32 { _ = bgra; _ = w; _ = h; return undefined; }

/// The id must not be used afterwards. 0 is ignored.
pub fn freeTexture(texid: u32) void { _ = texid; }

/// Draw a texture at its native size. 0 is ignored.
pub fn drawTexture(texid: u32, x: f32, y: f32) void { _ = texid; _ = x; _ = y; }

/// Draw a texture scaled to `w` by `h` with nearest-neighbor sampling. 0 is
/// ignored.
pub fn drawTextureScaled(texid: u32, x: f32, y: f32, w: f32, h: f32) void { _ = texid; _ = x; _ = y; _ = w; _ = h; }

pub fn drawLine(x1: f32, y1: f32, x2: f32, y2: f32, color: i32) void { _ = x1; _ = y1; _ = x2; _ = y2; _ = color; }

/// Outlined rectangle with a `line_width` stroke.
pub fn drawRect(x: f32, y: f32, w: f32, h: f32, color: i32, line_width: f32) void { _ = x; _ = y; _ = w; _ = h; _ = color; _ = line_width; }

pub fn drawFilledRect(x: f32, y: f32, w: f32, h: f32, color: i32) void { _ = x; _ = y; _ = w; _ = h; _ = color; }
pub fn drawCircle(x: f32, y: f32, radius: f32, color: i32, filled: bool) void { _ = x; _ = y; _ = radius; _ = color; _ = filled; }

/// Line whose color blends from `color1` at the first point to `color2` at
/// the second.
pub fn drawGradientLine(x1: f32, y1: f32, x2: f32, y2: f32, color1: i32, color2: i32) void { _ = x1; _ = y1; _ = x2; _ = y2; _ = color1; _ = color2; }

/// Filled rectangle with one color per corner; diagonal blends split along
/// the top-left to bottom-right diagonal.
pub fn drawGradientRect(x: f32, y: f32, w: f32, h: f32, top_left: i32, top_right: i32, bottom_right: i32, bottom_left: i32) void { _ = x; _ = y; _ = w; _ = h; _ = top_left; _ = top_right; _ = bottom_right; _ = bottom_left; }

/// Filled disc blending from `center` at its center to `edge` at its rim.
pub fn drawRadialCircle(x: f32, y: f32, radius: f32, center: i32, edge: i32) void { _ = x; _ = y; _ = radius; _ = center; _ = edge; }

/// Filled triangle with colors interpolated from its vertices.
pub fn drawGradientTriangle(x0: f32, y0: f32, x1: f32, y1: f32, x2: f32, y2: f32, color0: i32, color1: i32, color2: i32) void { _ = x0; _ = y0; _ = x1; _ = y1; _ = x2; _ = y2; _ = color0; _ = color1; _ = color2; }

/// Single-line text with its top-left at `(x, y)`; `size` is the font height
/// in pixels. At most 256 bytes are drawn; non-ASCII renders blank.
pub fn drawText(text: []const u8, x: f32, y: f32, size: f32, color: i32) void { _ = text; _ = x; _ = y; _ = size; _ = color; }

/// Like `drawText`, centered horizontally on `x`.
pub fn drawTextCentered(text: []const u8, x: f32, y: f32, size: f32, color: i32) void { _ = text; _ = x; _ = y; _ = size; _ = color; }

/// `drawText` with `std.fmt` formatting, e.g.
/// `drawTextFmt("range {d:.0}m", .{range}, x, y, 11.0, color)`. Output past
/// 256 bytes is truncated.
pub fn drawTextFmt(comptime fmt: []const u8, args: anytype, x: f32, y: f32, size: f32, color: i32) void { _ = fmt; _ = args; _ = x; _ = y; _ = size; _ = color; }

/// Like `drawTextFmt`, centered horizontally on `x`.
pub fn drawTextCenteredFmt(comptime fmt: []const u8, args: anytype, x: f32, y: f32, size: f32, color: i32) void { _ = fmt; _ = args; _ = x; _ = y; _ = size; _ = color; }

pub fn drawSphere3D(center: Vec3, radius: f32, color: i32) void { _ = center; _ = radius; _ = color; }
pub fn drawWireSphere3D(center: Vec3, radius: f32, color: i32) void { _ = center; _ = radius; _ = color; }

/// Capsule with its axis from `a` to `b`.
pub fn drawCapsule3D(a: Vec3, b: Vec3, radius: f32, color: i32) void { _ = a; _ = b; _ = radius; _ = color; }

pub fn drawWireCapsule3D(a: Vec3, b: Vec3, radius: f32, color: i32) void { _ = a; _ = b; _ = radius; _ = color; }

/// Oriented box with positive local `half_extents` and an xyzw unit
/// quaternion `rotation`.
pub fn drawBox3D(center: Vec3, half_extents: Vec3, rotation: Quat, color: i32) void { _ = center; _ = half_extents; _ = rotation; _ = color; }

pub fn drawBox3DWireframe(center: Vec3, half_extents: Vec3, rotation: Quat, color: i32) void { _ = center; _ = half_extents; _ = rotation; _ = color; }

/// Sphere blending from `color_a` at its `-axis` extreme to `color_b` at its
/// `+axis` extreme. `axis` must be finite and non-zero.
pub fn drawGradientSphere3D(center: Vec3, radius: f32, color_a: i32, color_b: i32, axis: Vec3) void { _ = center; _ = radius; _ = color_a; _ = color_b; _ = axis; }

/// Capsule blending from `color_a` at `a` to `color_b` at `b`; `a` and `b`
/// must differ.
pub fn drawGradientCapsule3D(a: Vec3, b: Vec3, radius: f32, color_a: i32, color_b: i32) void { _ = a; _ = b; _ = radius; _ = color_a; _ = color_b; }

/// Box like `drawBox3D`, blending from `color_a` at its `-axis` extreme to
/// `color_b` at its `+axis` extreme.
pub fn drawGradientBox3D(center: Vec3, half_extents: Vec3, rotation: Quat, color_a: i32, color_b: i32, axis: Vec3) void { _ = center; _ = half_extents; _ = rotation; _ = color_a; _ = color_b; _ = axis; }

/// Pack 0-255 channels into a draw color: red in the low byte, alpha in the
/// high byte (`0xAABBGGRR`).
pub fn rgba(r: i32, g: i32, b: i32, a: i32) i32 { _ = r; _ = g; _ = b; _ = a; return undefined; }
