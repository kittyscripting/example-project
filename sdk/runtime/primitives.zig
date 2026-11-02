const math = @import("math.zig");
const Vec3 = math.Vec3;
const Quat = math.Quat;

/// Line segment in world meters.
pub const Line = extern struct {
    from: Vec3,
    to: Vec3,
};

/// Sphere in world meters.
pub const Sphere = extern struct {
    center: Vec3,
    radius: f32,
};

/// Capsule in world meters, with its axis from `a` to `b`.
pub const Capsule = extern struct {
    a: Vec3,
    b: Vec3,
    radius: f32,
};

/// Oriented box in world meters.
pub const Box = extern struct {
    center: Vec3,
    /// Positive half-extents along the box's local axes.
    half_extents: Vec3,
    /// Unit quaternion from the box's local axes to world space.
    rotation: Quat,
};
