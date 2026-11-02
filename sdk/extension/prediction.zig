const runtime = @import("runtime");
const Actor = @import("actor.zig").Actor;
const Vec3 = runtime.Vec3;

/// offset in meters to add to the aim point so a projectile of
/// `projectile_speed` (m/s) and `projectile_gravity` (m/s²), launched
/// `projectile_launch_angle` radians above the aim direction after
/// `time_addition` seconds, intercepts `actor`. Null for hitscan, when
/// unsupported, or when no lead solves.
pub fn predict(actor: *const Actor, projectile_speed: f32, projectile_gravity: f32, projectile_launch_angle: f32, time_addition: f32) ?Vec3 { _ = actor; _ = projectile_speed; _ = projectile_gravity; _ = projectile_launch_angle; _ = time_addition; return undefined; }

/// `aim_point` moved by `predict`, or unchanged when there is no lead.
pub fn refine(actor: *const Actor, aim_point: Vec3, projectile_speed: f32, projectile_gravity: f32, projectile_launch_angle: f32) Vec3 { _ = actor; _ = aim_point; _ = projectile_speed; _ = projectile_gravity; _ = projectile_launch_angle; return undefined; }
