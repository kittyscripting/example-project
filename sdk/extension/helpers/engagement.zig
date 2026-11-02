const runtime = @import("runtime");
const motion = @import("motion.zig");
const future = @import("future.zig");
const target = @import("target.zig");
const Actor = @import("../actor.zig").Actor;
const LocalActor = @import("../local_actor.zig").LocalActor;
const Vec3 = runtime.Vec3;

/// Whether a living actor of `ctx.effect_target`'s side is inside the FOV and
/// Max Range of `ctx`, even when the tracker cannot select it now
/// (invincible, mid-dash or blink, hidden, or without hitboxes). Objects are
/// skipped: they are targets only while the view ray is on one.
pub fn targetInFov(actors: []Actor, local: *LocalActor, ctx: target.TargetCtx) bool { _ = actors; _ = local; _ = ctx; return undefined; }

/// Max engagement range for a projectile of `projectile_speed` m/s:
/// `base_range` scaled by the speed over a 125 m/s baseline.
pub fn predictionRange(base_range: f32, projectile_speed: f32) f32 { _ = base_range; _ = projectile_speed; return undefined; }

/// Target an engagement stays on once a tracker step selects it.
pub const Engagement = struct {
    /// Actor id of the engaged target; null between engagements.
    target_id: ?i32 = null,
    /// `tracker` step over the engaged actor alone while `target_id` is set,
    /// otherwise over `actors`, where a valid target becomes the engaged one.
    /// While an actor is engaged, a step over all of `actors` runs first as
    /// soon as another one preempts it (`helpers.target.preemptsEngagement`);
    /// it is kept only when it lands on the engaged actor or on a preemptor,
    /// so a scan that would switch the engagement for another reason leaves
    /// the tracker and the engagement as they were. A `trigger_only` target
    /// is returned for the tick only and never engaged.
    pub fn step(self: *Engagement, tracker: *target.TargetTracker, actors: []Actor, local: *LocalActor, ctx: target.TargetCtx, now_ms: f32) ?target.AimTarget { _ = self; _ = tracker; _ = actors; _ = local; _ = ctx; _ = now_ms; return undefined; }
    /// Clear the engaged target.
    pub fn end(self: *Engagement) void { _ = self; }
};

/// Motion history of the engaged target, restarted when the target changes,
/// and the newest teleport already reported.
pub const TargetMotion = struct {
    /// History `observe` feeds; the rhythm for `future` leads.
    tracker: motion.MotionTracker(Vec3) = .{},
    /// Feed `actor`'s newest transform samples into `tracker`, restarting the
    /// history and the teleport bookkeeping when `actor` is not the previous
    /// target.
    pub fn observe(self: *TargetMotion, actor: *const Actor, now_ms: f32, config: motion.Config) future.Observed { _ = self; _ = actor; _ = now_ms; _ = config; return undefined; }
    /// Whether `seen` holds a teleport on either channel newer than the last
    /// one reported, so each is reported once. Accuracy 100 never reports.
    pub fn teleported(self: *TargetMotion, seen: future.Observed, accuracy: u32, now_ms: f32) bool { _ = self; _ = seen; _ = accuracy; _ = now_ms; return undefined; }
    /// Clear `tracker`; the target and the reported teleport are kept.
    pub fn reset(self: *TargetMotion) void { _ = self; }
};

/// Whether `seen` holds an unexpected change on either channel younger than
/// 0.2 s scaled by `accuracy_mul` (`util.math.accuracyMul`). Changes stamped
/// ahead of the rendered pose (negative age) always count.
pub fn motionAborts(seen: future.Observed, accuracy_mul: f32) bool { _ = seen; _ = accuracy_mul; return undefined; }

/// Steering hold-off around the near-vertical cone, where yaw is
/// ill-defined.
pub const VerticalGuard = struct {
    /// True while `view_dir` or `target_dir` is near vertical
    /// (`steering.nearVertical`), and until 50 ms scaled by `accuracy_mul`
    /// (`util.math.accuracyMul`) after both leave the cone: Accuracy 1 ≈ 99
    /// ms, 50 = 50 ms, 100 = none.
    pub fn hold(self: *VerticalGuard, view_dir: Vec3, target_dir: Vec3, now_ms: f32, accuracy_mul: f32) bool { _ = self; _ = view_dir; _ = target_dir; _ = now_ms; _ = accuracy_mul; return undefined; }
};

/// Wait of a fresh stroke for the target to cross the crosshair by itself.
pub const CrossingWait = struct {
    /// Tick time (ms) the wait began; null when not waiting.
    start_ms: ?f32 = null,
    /// Whether a stroke of `movement_ms` should wait instead of moving:
    /// `actor`'s volumes cross the ray from `eye` along `view_dir` at the
    /// fire instant `fire_in` seconds ahead within the stroke's own duration
    /// (at most 250 ms), counted from the first waiting tick. Begins or ends
    /// the wait accordingly.
    pub fn wait(self: *CrossingWait, actor: *const Actor, shot: future.Shot, eye: Vec3, eye_velocity: Vec3, view_dir: Vec3, fire_in: f32, now_ms: f32, critical_only: bool, movement_ms: f32, rhythm: *const motion.MotionTracker(Vec3), config: motion.Config) bool { _ = self; _ = actor; _ = shot; _ = eye; _ = eye_velocity; _ = view_dir; _ = fire_in; _ = now_ms; _ = critical_only; _ = movement_ms; _ = rhythm; _ = config; return undefined; }
};

/// Lean toward `actor`'s motion across the line of sight from `eye`, per
/// unit of a volume's radius: up to 0.3, ramped in up to a 3 m/s crossing
/// speed. Zero for hitscan (`projectile_speed` 0) and targets not crossing
/// the view.
pub fn frontLean(actor: *const Actor, eye: Vec3, projectile_speed: f32) Vec3 { _ = actor; _ = eye; _ = projectile_speed; return undefined; }

/// Radius of `actor`'s first critical volume: a sphere's or capsule's radius,
/// or a box's smallest half-extent. 0 without critical volumes.
pub fn criticalRadius(actor: *const Actor) f32 { _ = actor; return undefined; }
