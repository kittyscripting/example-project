const runtime = @import("runtime");

/// Pose and motion of an entity in meters.
pub const Transform = struct {
    /// Meters.
    position: runtime.Vec3 = .{},
    rotation: runtime.Quat = .{},
    /// Meters per second.
    velocity: runtime.Vec3 = .{},
};
