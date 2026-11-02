const runtime = @import("runtime");
const Vec3 = runtime.Vec3;
const Actor = @import("../actor.zig").Actor;
const LocalActor = @import("../local_actor.zig").LocalActor;
const slots = @import("slots.zig");
const EffectTarget = @import("../gun.zig").EffectTarget;

/// Distance (m) the configured FOV angle is measured at.
pub const fov_reference_distance: f32 = 10.0;

/// World-space miss radius (m) of a `fov_deg` cone at
/// `fov_reference_distance`.
pub fn fovRadius(fov_deg: f32) f32 { _ = fov_deg; return undefined; }

/// Whether `point` is inside the view cone from `eye` along `view_dir`.
/// `fov_deg` is the full cone angle at `fov_reference_distance`: the cone holds
/// the points whose angular distance from the view ray is within
/// `atan((fovRadius(fov_deg) + lead_m) / distance)`, so the area it covers
/// around a target is the same size at every distance. `lead_m` is the length
/// (m) of the shot lead `point` carries, zero for an unled point; a longer lead
/// widens the area by the same amount. Above 170 every point is inside.
pub fn isInFov(eye: Vec3, view_dir: Vec3, point: Vec3, fov_deg: f32, lead_m: f32) bool { _ = eye; _ = view_dir; _ = point; _ = fov_deg; _ = lead_m; return undefined; }

/// Result of `TargetTracker.step`. `actor` stays valid until the next tick.
pub const AimTarget = struct {
    actor: *Actor,
    /// Unled aim point in meters. Selection judged the target at this
    /// point plus the shot lead; callers add their own lead.
    aim_point: Vec3,
    /// Best candidate score of this step (lower is better); `floatMax(f32)`
    /// when no candidate scored.
    priority: f32,
    /// When false, `actor` and `aim_point` are unspecified.
    is_valid: bool,
    /// `actor` is an object (`isObject`) the current view ray is already on:
    /// fire at the current view without steering. `aim_point` is the ray's
    /// entry point on it.
    trigger_only: bool = false,
};

/// Which point of a target to aim at. Every mode needs some hitbox volume;
/// actors without the required volumes are skipped.
pub const HitboxPick = enum {
    /// Center of the first critical volume, or `.body` when the actor has no
    /// critical volume.
    defined,
    /// Center of the first critical volume; actors without one are skipped.
    head,
    /// Center of the bounds of all volumes.
    body,
    /// The actor origin. Selection still requires some valid volume.
    origin,
    /// The volume point needing the smallest view correction.
    nearest,
};

/// Candidate scoring for `TargetTracker.step`; lower wins.
pub const TargetScore = enum {
    /// Fitts' law, `theta * log2(theta / width + 1)`: favors large or near
    /// targets close to the crosshair.
    fitts,
    /// Angle to the crosshair.
    crosshair,
};

/// Per-update selection settings for `TargetTracker.step`.
pub const TargetCtx = struct {
    /// Full view-cone angle in degrees at `fov_reference_distance`: the cone is
    /// a world-space radius there, the same size at every target distance.
    fov_deg: f32,
    /// Multiplier on `fov_deg`.
    fov_scale: f32 = 1.0,
    /// Minimum milliseconds between target switches, and between candidate
    /// scans while a target is held.
    swap_delay_ms: f32 = 150.0,
    /// Keep the current target over better candidates and through brief
    /// out-of-view gaps; without it the target is kept only while its
    /// predicted point stays in view.
    lock_target: bool = false,
    /// aim point selection.
    hitbox: HitboxPick = .defined,
    score: TargetScore = .fitts,
    /// Maximum distance in meters from the local actor to a candidate's live
    /// `transform` position; 0 is unlimited.
    max_range: f32 = 0,
    /// Drops a candidate, and a held lock, whose recent motion is unnatural
    /// (dash, blink, sharp turn at speed). Actors with `target_priority` above
    /// 0 are exempt: the provider marks them while a script moves them.
    reject_unnatural_motion: bool = false,
    effect_target: EffectTarget = .enemy,
    /// Entity type of the local actor's own deployables that are also
    /// targetable; 0 disables. Copy of `Gun.owned_target_def`.
    owned_target_def: u64 = 0,
};

/// Which side a slot targets given its two activation keys. The primary key
/// keeps the slot's own `effect_target`. The ally key, held without the
/// primary key, engages a slot that can hit allies against allies only; it is
/// ignored for slots that hit only enemies. Null when neither key engages the
/// slot.
pub fn keyedEffectTarget(slot_target: EffectTarget, primary_down: bool, ally_down: bool) ?EffectTarget { _ = slot_target; _ = primary_down; _ = ally_down; return undefined; }

/// Whether the player is firing the other weapon than `slot`: `slot` is on
/// primary or secondary fire, its button is up, and the other fire button is
/// held and drives a steered slot of the avatar. A custom activation key engages
/// every slot at once, so this keeps it off the weapon that is not being
/// fired. False for slots on other buttons, and while the other fire button
/// drives no steered slot (e.g. it zooms a scope).
pub fn firesOtherWeapon(local: *const LocalActor, slot: slots.AimSlotRef) bool { _ = local; _ = slot; return undefined; }

/// Target selection with locking: switches are debounced by `swap_delay_ms`,
/// a held target is re-scanned at most once per `swap_delay_ms`, and with
/// `lock_target` a target survives a brief out-of-view gap (500 ms by
/// default).
pub const TargetTracker = struct {
    pub fn reset(self: *TargetTracker) void { _ = self; }
    /// Pick a target from `actors` for `local`. `now_ms` drives the lock,
    /// grace, and debounce timers. An eligible object (`isObject`) is the
    /// target only while the current view ray is on it; it then wins over
    /// every other candidate with `trigger_only` set, leaves the lock
    /// untouched, and is otherwise never scanned or locked. The FOV test,
    /// scoring, and visibility judge the `pickAimPoint` position plus the
    /// `projectile_speed`/`projectile_gravity` lead for a shot fired now; range
    /// and eligibility still use the live actor. An eligible owned target
    /// always wins over every other scanned candidate and takes over any lock
    /// without debounce. Otherwise a higher `Actor.target_priority` always
    /// wins, and a candidate above the held target's tier takes over the lock
    /// the same way. While a target is held other actors are only scanned
    /// once per `swap_delay_ms` (never with `lock_target`).
    pub fn step(self: *TargetTracker, actors: []Actor, local: *LocalActor, ctx: TargetCtx, now_ms: f32) AimTarget { _ = self; _ = actors; _ = local; _ = ctx; _ = now_ms; return undefined; }
};

/// Whether `actor` is a stationary object (turret, explosive, or support
/// deployable): a target only while the view ray is already on it.
pub fn isObject(actor: *const Actor) bool { _ = actor; return undefined; }

/// The aim point of `actor` for `mode`, or null when the required volumes
/// are missing. `.nearest` measures from `eye` along `view_dir`.
pub fn pickAimPoint(actor: *Actor, mode: HitboxPick, eye: Vec3, view_dir: Vec3) ?Vec3 { _ = actor; _ = mode; _ = eye; _ = view_dir; return undefined; }

/// The tighter of two range caps where 0 means unlimited.
pub fn combineMaxRange(a: f32, b: f32) f32 { _ = a; _ = b; return undefined; }
