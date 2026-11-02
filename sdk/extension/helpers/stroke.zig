const runtime = @import("runtime");
const Actor = @import("../actor.zig").Actor;
const Vec3 = runtime.Vec3;

/// Hitbox scale a shot must land inside for the stroke to count as reaching
/// the target: the real geometry, 2% inward.
pub const fire_hitbox_scale: f32 = 0.98;

/// Decay weight below which the post-shot follow-through ends (~75 ms after
/// the shot).
pub const follow_end_weight: f32 = 0.05;

/// Lognormal stroke from the view toward a target direction, with the
/// player's own movement accounted for.
pub const Stroke = struct {
    /// The stroke is running.
    active: bool = false,
    /// Actor id the stroke aims at.
    target_id: i32 = 0,
    movement_ms: f32 = 0.0,
    /// Start a stroke from `view_dir` toward `target_dir`, `angular_dist_deg`
    /// of sweep and `movement_ms` of full-length movement time, covering
    /// `pitchStrength(accuracy)` of the vertical delta. Resets every field.
    pub fn start(self: *Stroke, view_dir: Vec3, target_dir: Vec3, angular_dist_deg: f32, movement_ms: f32, accuracy: u32) void { _ = self; _ = view_dir; _ = target_dir; _ = angular_dist_deg; _ = movement_ms; _ = accuracy; }
    /// Stroke time (ms) elapsed at `now_ms`, never negative.
    pub fn elapsedMs(self: *const Stroke, now_ms: f32) f32 { _ = self; _ = now_ms; return undefined; }
    /// Whether the plan has run out at `elapsed_ms`: its progress reached
    /// 0.98, or twice the movement time passed.
    pub fn complete(self: *const Stroke, elapsed_ms: f32) bool { _ = self; _ = elapsed_ms; return undefined; }
    /// Elapsed stroke time (ms) at which the plan first reaches the target
    /// direction (`overshoot · progress >= 1`), bisected over the stroke's
    /// `[0, 2 · movement_ms]` window; the window end when it never does.
    /// Computed once per plan.
    pub fn crossingMs(self: *Stroke) f32 { _ = self; return undefined; }
    /// Re-aim the active stroke at a moved target direction without
    /// restarting it from rest. First keeps the clock: `rel0` is rescaled so
    /// the plan at the previous tick's progress (where the current view was
    /// written) starts from the current view. When that plan would move
    /// faster than the stroke's planned peak, or has already crossed the
    /// target, the clock is rewound to the earliest point at or before the
    /// peak whose rescaled plan moves at the current speed, so the view keeps
    /// its pace instead of stalling. Returns false, leaving the stroke
    /// unchanged, only when no plan fits.
    pub fn replan(self: *Stroke, view_dir: Vec3, target_dir: Vec3, now_ms: f32, dt_ms: f32) bool { _ = self; _ = view_dir; _ = target_dir; _ = now_ms; _ = dt_ms; return undefined; }
    /// Direction from `eye` the stroke steers around this tick. The anchor
    /// moves with the target's velocity; the rest of the live `aim_point`'s
    /// change (lead and drop updates, hitbox jumps) is absorbed in proportion
    /// to the plan's progress over what remains to the crossing, so it bends
    /// the stroke's path without changing its speed. From the crossing on the
    /// anchor is the live point. Reads the previous tick's progress, so call
    /// it before `step`.
    pub fn steerDir(self: *Stroke, eye: Vec3, aim_point: Vec3, target_velocity: Vec3, elapsed_ms: f32, dt: f32) Vec3 { _ = self; _ = eye; _ = aim_point; _ = target_velocity; _ = elapsed_ms; _ = dt; return undefined; }
    /// The stroke's view direction at `elapsed_ms`: the target-relative plan
    /// `rel0·(1 − overshoot·progress)` plus noise, around `aim_dir`, with the
    /// pitch term's progress scaled by `pitchStrength`. With `fired`, each
    /// plan step is weighted by the post-shot decay, so the view keeps the
    /// stroke's motion and comes to rest.
    pub fn step(self: *Stroke, view_dir: Vec3, elapsed_ms: f32, dt_seconds: f32, aim_dir: Vec3, fired: bool) Vec3 { _ = self; _ = view_dir; _ = elapsed_ms; _ = dt_seconds; _ = aim_dir; _ = fired; return undefined; }
    /// Whether, before the shot, the player's own unspent movement already
    /// reaches the plan's end, so the stroke has nothing left to move.
    pub fn playerCoveredPlan(self: *const Stroke, fired: bool) bool { _ = self; _ = fired; return undefined; }
    /// Whether the player's own movement left the view off the plan by more
    /// than the target's angular radius, so a completed stroke has nothing to
    /// fire at. Movement past the plan's end is measured from it.
    pub fn playerTookOver(self: *const Stroke, actor: *const Actor, eye: Vec3, fired: bool) bool { _ = self; _ = actor; _ = eye; _ = fired; return undefined; }
    /// Start the follow-through of a shot that did not complete the stroke.
    /// Returns whether the stroke keeps running; false means it ended and the
    /// caller resets it.
    pub fn beginFollow(self: *Stroke, done: bool) bool { _ = self; _ = done; return undefined; }
    /// Weight of the follow-through step at `elapsed_ms`, decaying
    /// exponentially from 1.0 at the shot with time constant 25 ms.
    pub fn followWeightAt(self: *const Stroke, elapsed_ms: f32) f32 { _ = self; _ = elapsed_ms; return undefined; }
    /// Whether the follow-through has run out at `elapsed_ms`: the plan
    /// completed, or its decay weight fell below `follow_end_weight`.
    pub fn followEnded(self: *const Stroke, elapsed_ms: f32) bool { _ = self; _ = elapsed_ms; return undefined; }
    /// One tick of a shot's follow-through: the plan keeps decelerating, but
    /// each step the view takes is weighted by the post-shot decay, so it
    /// keeps the stroke's motion and comes to rest within ~75 ms. Returns the
    /// view direction to write, or null once the follow-through has run out.
    pub fn followStep(self: *Stroke, view_dir: Vec3, eye: Vec3, aim_point: Vec3, target_velocity: Vec3, now_ms: f32, dt: f32) ?Vec3 { _ = self; _ = view_dir; _ = eye; _ = aim_point; _ = target_velocity; _ = now_ms; _ = dt; return undefined; }
    /// Whether the stroke can still put the ray on the target's hitbox: yaw
    /// on the live aim direction `aim_dir`, pitch at the plan's closest
    /// approach to it. The steer anchor trails the live point while it
    /// absorbs motion, so it is not used here. A stroke with `pitchStrength`
    /// below 1 stops short vertically, so a target far enough above or below
    /// is out of reach.
    pub fn canReachHitbox(self: *const Stroke, actor: *const Actor, eye: Vec3, aim_dir: Vec3, lead: Vec3, critical_only: bool) bool { _ = self; _ = actor; _ = eye; _ = aim_dir; _ = lead; _ = critical_only; return undefined; }
};

/// Fraction of the vertical delta a stroke covers: Accuracy / 100, so 50
/// covers half and 100 all of it.
pub fn pitchStrength(accuracy: u32) f32 { _ = accuracy; return undefined; }

/// Full-length movement time (ms) of the Speed setting: 1 => 3000 ms,
/// 50 => 362.4 ms, 100 => 120 ms. `speed` is clamped to 1..100.
pub fn speedMovementMs(speed: u32) f32 { _ = speed; return undefined; }

/// Movement time (ms) of a stroke over `angular_dist_deg` onto a target
/// `width_deg` wide: `full_ms` scaled by the Fitts index of difficulty
/// `log2(D / W + 1)` relative to a 3° stroke onto the same target, so a short
/// correction does not crawl for the full time.
pub fn movementTimeMs(full_ms: f32, angular_dist_deg: f32, width_deg: f32) f32 { _ = full_ms; _ = angular_dist_deg; _ = width_deg; return undefined; }

/// Estimated ms until a stroke of `movement_ms` started now from `view_dir`
/// first puts the ray on `actor`'s hitboxes, or reaches the plan's crossing
/// when it never does. Uses the noise-free plan at the centre of the stroke's
/// randomized shape (sigma 0.25, peak at 35% of the movement time, overshoot
/// 1.02).
pub fn arrivalMs(actor: *const Actor, eye: Vec3, view_dir: Vec3, target_dir: Vec3, lead: Vec3, movement_ms: f32, accuracy: u32, critical_only: bool) f32 { _ = actor; _ = eye; _ = view_dir; _ = target_dir; _ = lead; _ = movement_ms; _ = accuracy; _ = critical_only; return undefined; }
