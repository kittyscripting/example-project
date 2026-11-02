/// Angular drift (rad/s) below which the target counts as settled relative
/// to the viewer. About 0.6 deg/s: slower than any deliberate movement at
/// engagement range, above sensor jitter.
pub const settleDriftRadPerSec: f32 = 0.01;

/// Core blend targeted while outside a volume but drifting, so re-entry lands
/// inside the volume instead of stopping on its edge.
pub const approachBlend: f32 = 0.35;

/// Time constant (s) for the outside approach blend to rise.
pub const attackSeconds: f32 = 0.08;

/// Time constant (s) for the outside approach blend to fall.
pub const releaseSeconds: f32 = 0.2;

/// What a tick does about the inside/outside state of the view ray.
pub const Action = enum {
    /// Outside a volume: steer toward the (possibly core-blended) point.
    steer,
    /// Inside and the target drifts across the view: turn by its motion only.
    follow,
    /// Inside and settled: emit no input.
    idle,
};

/// Inside/outside action for one tick at `driftRadPerSec`.
pub fn action(inside: bool, driftRadPerSec: f32) Action { _ = inside; _ = driftRadPerSec; return undefined; }

/// Outside-approach blend of the point steered toward.
pub const Transition = struct {
    /// Outside-approach blend: 0 = the nearest (edge) point, `approachBlend`
    /// = partway toward the volume core.
    blend: f32 = 0.0,
    /// Clear the blend.
    pub fn reset(self: *Transition) void { _ = self; }
    /// Advance the approach blend by `dt` seconds: it rises toward
    /// `approachBlend` only while outside a volume with the target drifting.
    pub fn update(self: *Transition, dt: f32, inside: bool, driftRadPerSec: f32) void { _ = self; _ = dt; _ = inside; _ = driftRadPerSec; }
};

/// Share of the target's relative motion followed on one axis for a
/// Smoothness setting: 50 follows half, 1 nearly all, 100 none.
pub fn followShare(smoothness: u32) f32 { _ = smoothness; return undefined; }

/// Bias gain (1/s) toward the lead goal at Smoothness <= 50.
pub const biasGainPerSec: f32 = 10.0;

/// Bias speed cap as a multiple of the across-view relative speed.
pub const biasCap: f32 = 1.0;

/// Lead time (s) of the inside goal along the across-view relative velocity.
pub const leadSeconds: f32 = 0.1;

/// Lead distance cap as a fraction of the target radius.
pub const maxLeadFraction: f32 = 0.5;

/// Bias gain (1/s) for a Smoothness setting: `biasGainPerSec` up to 50,
/// falling as 50/smoothness above it (half at 100).
pub fn biasGain(smoothness: u32) f32 { _ = smoothness; return undefined; }

/// Inside goal: `core` shifted by `relVelPerp * lead_seconds`, the shift
/// clamped to length `max_lead`. `core` for nonfinite lead input.
pub fn leadGoal(core: anytype, relVelPerp: @TypeOf(core), lead_seconds: f32, max_lead: f32) @TypeOf(core) { _ = relVelPerp; _ = lead_seconds; _ = max_lead; return undefined; }

/// Bias displacement for one tick: the across-view component of
/// `goal - rayPoint` scaled by `min(1, gain*dt)`, length clamped to
/// `cap * |relVelPerp| * dt`. Zero for nonfinite or degenerate input.
pub fn biasDisplacement(rayPoint: anytype, goal: @TypeOf(rayPoint), viewDir: @TypeOf(rayPoint), relVelPerp: @TypeOf(rayPoint), dt: f32, gain: f32, cap: f32) @TypeOf(rayPoint) { _ = goal; _ = viewDir; _ = relVelPerp; _ = dt; _ = gain; _ = cap; return undefined; }

/// View direction after following the target for `dt` seconds: the point on
/// the current view ray at the target's range moves by the relative velocity
/// (`targetVel - eyeVel`) scaled per component by `strength`, plus `bias`
/// (meters at target range, already weighted). Only the across-the-view
/// component changes the direction. Null for degenerate geometry (target
/// behind or at the eye).
pub fn followDirection(eye: anytype, viewDir: @TypeOf(eye), targetPos: @TypeOf(eye), relVel: @TypeOf(eye), dt: f32, strength: @TypeOf(eye), bias: @TypeOf(eye)) ?@TypeOf(eye) { _ = viewDir; _ = targetPos; _ = relVel; _ = dt; _ = strength; _ = bias; return undefined; }

/// Angular rate (rad/s) at which `targetPos` moves across the view from
/// `eyePos`, from the relative velocity's component perpendicular to the line
/// of sight. Zero for coincident points or nonfinite input.
pub fn driftRate(eyePos: anytype, eyeVel: @TypeOf(eyePos), targetPos: @TypeOf(eyePos), targetVel: @TypeOf(eyePos)) f32 { _ = eyeVel; _ = targetPos; _ = targetVel; return undefined; }

/// Core of the valid volume whose core lies closest (angularly) to `viewDir`
/// from `eye`: sphere center, box center, or the point on a capsule's axis
/// nearest the view ray. `lead` translates volumes as for projectile lead.
/// Null when the actor publishes no valid volume.
pub fn corePoint(hitboxes: anytype, eye: anytype, viewDir: @TypeOf(eye), lead: @TypeOf(eye)) ?@TypeOf(eye) { _ = hitboxes; _ = viewDir; _ = lead; return undefined; }
