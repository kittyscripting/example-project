const runtime = @import("runtime");
const motion = @import("motion.zig");
const Actor = @import("../actor.zig").Actor;
const AimSlotRef = @import("slots.zig").AimSlotRef;
const Vec3 = runtime.Vec3;
const Tracker = motion.MotionTracker(Vec3);
const Config = motion.Config;

/// Hitbox scale a shot must land inside for the view to hold still.
pub const hold_scale: f32 = 0.8;

/// Most release instants `hitsWithin` tests.
pub const max_samples: usize = 6;

/// Seconds the newest transform sample lies ahead of now (measured, not
/// extrapolated); 0 when none.
pub fn knownSeconds(actor: *const Actor) f32 { _ = actor; return undefined; }

/// Seconds until `slot` can fire again; 0 when ready or cooldown is unknown.
pub fn nextFireSeconds(slot: AimSlotRef) f32 { _ = slot; return undefined; }

/// Projectile parameters of a shot.
pub const Shot = struct {
    /// Meters per second; 0 is hitscan.
    projectile_speed: f32 = 0,
    /// Meters per second squared.
    projectile_gravity: f32 = 0,
    /// Radians the launch direction is pitched above the aim direction.
    projectile_launch_angle: f32 = 0,
    /// Parameters of `slot`.
    pub fn of(slot: AimSlotRef) Shot { _ = slot; return undefined; }
};

/// Lead correction in meters for a shot released in `fire_in` seconds,
/// accounting for motion already known ahead of the rendered pose; `rhythm`'s
/// lead scale shortens only the extrapolated part.
pub fn shotOffset(actor: *const Actor, shot: Shot, fire_in: f32, rhythm: ?*const Tracker, config: Config) Vec3 { _ = actor; _ = shot; _ = fire_in; _ = rhythm; _ = config; return undefined; }

/// Whether a shot along `view_dir` from `eye`, moving at `eye_velocity`, lands
/// inside `actor`'s hitboxes at some release instant in `[fire_in, fire_in + slack]`.
pub fn hitsWithin(actor: *const Actor, shot: Shot, eye: Vec3, eye_velocity: Vec3, view_dir: Vec3, fire_in: f32, slack: f32, scale: f32, critical_only: bool, rhythm: ?*const Tracker, config: Config) bool { _ = actor; _ = shot; _ = eye; _ = eye_velocity; _ = view_dir; _ = fire_in; _ = slack; _ = scale; _ = critical_only; _ = rhythm; _ = config; return undefined; }

/// Strongest motion change per channel since the previous `observe`.
pub const Observed = struct {
    changes: motion.Changes = .{},
    /// Age in seconds of the sample behind `changes.horizontal`; negative
    /// while it lies ahead of the rendered pose; 0 for `.none`.
    horizontal_age: f32 = 0,
    /// Same as `horizontal_age`, for `changes.vertical`.
    vertical_age: f32 = 0,
};

/// Feed `tracker` every transform sample of `actor` newer than its last one,
/// including samples stamped ahead of now.
pub fn observe(tracker: *Tracker, actor: *const Actor, now_ms: f32, config: Config) Observed { _ = tracker; _ = actor; _ = now_ms; _ = config; return undefined; }
