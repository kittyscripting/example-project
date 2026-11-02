const runtime = @import("runtime");
const Vec3 = runtime.Vec3;

/// The eight world corners of an oriented box. Bit 0 of the index selects
/// +X, bit 1 +Y, and bit 2 +Z; the rotation is normalized first.
pub fn boxCorners(box: anytype) [8]Vec3 { _ = box; return undefined; }

/// Angular width in degrees of the actor's first valid volume (capsules,
/// then spheres, then boxes) seen from `eye`. Boxes use their true angular
/// extent; capsules and spheres use their radius at the actor's distance.
pub fn targetWidthDeg(actor: anytype, eye: Vec3) f32 { _ = actor; _ = eye; return undefined; }

/// Radius of the first valid capsule, sphere, or box; for a box, its
/// smallest half-extent.
pub fn targetRadius(actor: anytype) f32 { _ = actor; return undefined; }

/// Signed yaw and pitch from one direction to another, in radians, and
/// their length.
pub const YawPitchDelta = struct {
    yaw: f32,
    pitch: f32,
    magnitude: f32,
};

/// Yaw/pitch difference from `view_dir` to `dir_to_target`, each wrapped to
/// `[-π, π]`.
pub fn yawPitchDistance(view_dir: Vec3, dir_to_target: Vec3) YawPitchDelta { _ = view_dir; _ = dir_to_target; return undefined; }

/// `base_dir` turned by `yaw_rad` about world up and `pitch_rad` upward, with
/// pitch clamped short of vertical.
pub fn perturbDirection(base_dir: Vec3, yaw_rad: f32, pitch_rad: f32) Vec3 { _ = base_dir; _ = yaw_rad; _ = pitch_rad; return undefined; }

/// Whether `actor` has a valid volume, optionally a critical one.
pub fn hasUsableHitboxes(actor: anytype, critical_only: bool) bool { _ = actor; _ = critical_only; return undefined; }

/// Whether `point` is in or on a valid volume, optionally a critical one.
pub fn pointInHitboxes(actor: anytype, point: Vec3, critical_only: bool) bool { _ = actor; _ = point; _ = critical_only; return undefined; }

/// Whether the ray from `ray_start` along `ray_dir` hits a valid volume,
/// optionally a critical one. Each volume is moved by `lead` (e.g. motion
/// over the flight time); a `scale` below 1 shrinks radii and box extents
/// and pulls sphere/capsule points toward the actor's vertical axis.
/// Tangent contact and starting inside count as hits.
pub fn rayHitsHitboxes(actor: anytype, ray_start: Vec3, ray_dir: Vec3, lead: Vec3, scale: f32, critical_only: bool) bool { _ = actor; _ = ray_start; _ = ray_dir; _ = lead; _ = scale; _ = critical_only; return undefined; }

/// Distance along the segment `from` -> `to` to the first valid volume
/// entered, in the endpoints' units; null when the segment misses. Starting
/// inside a volume is distance 0; tangent contact and entering exactly at
/// `to` count.
pub fn rayHitboxEntryDistance(actor: anytype, from: Vec3, to: Vec3) ?f32 { _ = actor; _ = from; _ = to; return undefined; }

/// Where a crosshair turn first meets an actor: `t` is the fraction of the
/// turn, `dir` the crosshair direction there, and `distance` how far along
/// `dir` from the eye the ray enters the volumes.
pub const SweepHit = struct {
    t: f32,
    dir: Vec3,
    distance: f32,
};

/// The first point of the crosshair turn from `from` to `to`, seen from
/// `eye`, where the ray enters the actor's `lead`-shifted volumes, or crosses
/// the actor's vertical line within `margin` meters of them (e.g. just over
/// the head). Null when the turn misses, has no length, or is wider than 45°.
pub fn sweepHit(actor: anytype, eye: Vec3, from: Vec3, to: Vec3, lead: Vec3, margin: f32, critical_only: bool) ?SweepHit { _ = actor; _ = eye; _ = from; _ = to; _ = lead; _ = margin; _ = critical_only; return undefined; }

/// The valid volume point needing the smallest angular correction from
/// `view_dir`. A point where the view ray already enters a volume wins;
/// otherwise the closest silhouette point of the spheres and capsules and
/// the corners and edges of the boxes.
pub fn nearestHitboxPoint(actor: anytype, eye: Vec3, view_dir: Vec3, critical_only: bool) ?Vec3 { _ = actor; _ = eye; _ = view_dir; _ = critical_only; return undefined; }
