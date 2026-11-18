const runtime = @import("runtime");

/// Where and when a projectile meets its target.
pub const Intercept = struct {
    /// Intercept position in world-space meters.
    position: runtime.Vec3,
    /// Flight time in seconds.
    time: f32,
};

/// Solve a linear-motion intercept using meter positions, target velocity,
/// and projectile speed in meters/s.
pub fn linearIntercept(
    shooter: runtime.Vec3,
    target: runtime.Vec3,
    velocity: runtime.Vec3,
    projectile_speed: f32,
) ?Intercept { _ = shooter; _ = target; _ = velocity; _ = projectile_speed; return undefined; }
