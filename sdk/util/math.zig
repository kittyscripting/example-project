const std = @import("std");
const runtime = @import("runtime");

/// π as `f32`.
pub const pi: f32 = @floatCast(std.math.pi);

/// 2π.
pub const tau: f32 = pi * 2.0;

/// Degrees per radian.
pub const rad_to_deg: f32 = 180.0 / pi;

/// Radians per degree.
pub const deg_to_rad: f32 = pi / 180.0;

/// Wrap `radians` into the range `[-π, π]`.
pub fn normalizeRadians(radians: f32) f32 { _ = radians; return undefined; }

/// Clamp a pitch angle to the near-vertical bounds ±1.553343 rad (±89°).
pub fn clampPitch(pitch: f32) f32 { _ = pitch; return undefined; }

/// Angle in degrees between directions `a` and `b` (both normalized first;
/// equal directions yield 0).
pub fn angleDeg(a: runtime.Vec3, b: runtime.Vec3) f32 { _ = a; _ = b; return undefined; }

/// Decompose direction `dir` into `Vec2(yaw, pitch)`: yaw is `atan2(z, x)`
/// radians in the XZ plane; pitch is `asin(y)` radians.
pub fn yawPitch(dir: runtime.Vec3) runtime.Vec2 { _ = dir; return undefined; }

/// Build a unit direction from `yaw` and `pitch` radians (inverse of
/// `yawPitch`).
pub fn fromYawPitch(yaw: f32, pitch: f32) runtime.Vec3 { _ = yaw; _ = pitch; return undefined; }

/// `value` as a float, for integer settings used in float math.
pub fn u32ToF32(value: u32) f32 { _ = value; return undefined; }

/// Clamp `value` into the inclusive range `[low, high]`.
pub fn clampU32(value: u32, low: u32, high: u32) u32 { _ = value; _ = low; _ = high; return undefined; }

/// Map accuracy (clamped to `[1, 100]`) to a multiplier in `[0, 1.98]`;
/// 50 maps to 1.0 and 100 to 0.
pub fn accuracyMul(accuracy: u32) f32 { _ = accuracy; return undefined; }

/// Seconds since the previous `now_seconds`, updating `last_seconds`; `1/60`
/// when the clock did not advance, so the result is positive.
pub fn tickDeltaSeconds(now_seconds: f32, last_seconds: *f32) f32 { _ = now_seconds; _ = last_seconds; return undefined; }

/// Natural logarithm of `x`; returns 0 for non-positive input.
pub fn logf(x: f32) f32 { _ = x; return undefined; }

/// `e` raised to `x`.
pub fn expf(x: f32) f32 { _ = x; return undefined; }
