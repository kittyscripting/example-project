const runtime = @import("runtime");
const Transform = @import("transform.zig").Transform;
const TransformSample = @import("transform_history.zig").TransformSample;
const Ability = @import("ability.zig").Ability;
const Gun = @import("gun.zig").Gun;
const HealthPools = @import("health_pool.zig").HealthPools;
const Stats = @import("stats.zig").Stats;
const Skeleton = @import("skeleton.zig").Skeleton;
const HitboxSet = @import("hitbox.zig").HitboxSet;
const Team = @import("team.zig").Team;

/// Behavioral class of an actor, independent of its numeric `type_id`:
/// - `.player`: mobile combatant character.
/// - `.turret`: stationary automated attacker.
/// - `.explosive`: detonating deployable.
/// - `.support`: stationary deployable or world object with no attack of
/// its own (barrier, wall, pad, field, drone, practice target).
/// - `.unknown`: unrecognized role; full actor state, but no kind-specific
/// abilities or guns.
pub const ActorKind = enum {
    player,
    turret,
    explosive,
    support,
    unknown,
};

/// One actor in the scene. Pointers and slices in this struct stay valid
/// until the next tick.
pub const Actor = struct {
    id: i32,
    /// Type id in the current title's vocabulary: entity definition, or
    /// another stable id.
    type_id: u64,
    kind: ActorKind = .player,
    /// Relationship to the local actor.
    team: Team = .unknown,
    /// Position in meters.
    transform: Transform = .{},
    /// Meters per second.
    velocity: runtime.Vec3 = .{},
    /// Maximum fall speed for motion prediction in m/s; at or below 1 means
    /// no limit.
    terminal_velocity: f32 = 0,
    /// Horizontal damping for motion prediction.
    horizontal_drag: f32 = 0,
    /// Downward acceleration for motion prediction in m/s², along -y.
    gravity: f32 = 0,
    on_ground: bool = false,
    /// Id of the owning actor (e.g. the thrower of a projectile); 0 when
    /// unowned.
    master_entity: u32 = 0,
    /// Recent transform history, newest first. Leading samples may be
    /// stamped after now; see `transformAt`.
    transform_history: []const TransformSample = &.{},
    health: f32 = 0,
    max_health: f32 = 0,
    /// Armor, shields, and other extra pools.
    health_pools: ?*HealthPools = null,
    /// Cannot be damaged.
    is_invincible: bool = false,
    /// Cannot be affected by normal interactions.
    is_invulnerable: bool = false,
    /// Visible from the local camera. False when visibility was not
    /// established (obstructed or unknown).
    is_visible: bool = false,
    /// Targeting tier set by the provider; 0 for ordinary actors.
    /// `sdk.helpers.target.TargetTracker` always prefers an eligible
    /// candidate of a higher tier, and one above the held target's tier
    /// takes over the lock at once.
    target_priority: u8 = 0,
    /// Set statuses: bit `@intFromEnum(s)` of the title SDK's status enum.
    status: u64 = 0,
    /// Bits of `status` the provider reads for this actor; other bits are
    /// unknown and stay 0.
    status_known: u64 = 0,
    /// Title-defined stat values.
    stats: ?*Stats = null,
    abilities: []Ability = &.{},
    guns: []Gun = &.{},
    skeleton: ?*Skeleton = null,
    hitboxes: ?*HitboxSet = null,
    /// Copy of the ability slot declared as `A` for this actor's kind.
    pub fn ability(self: *const Actor, comptime A: type) Ability { _ = self; _ = A; return undefined; }
    /// Copy of the gun slot declared as `G` for this actor's kind.
    pub fn gun(self: *const Actor, comptime G: type) Gun { _ = self; _ = G; return undefined; }
    /// Whether status `s` is set, `s` being a tag of the title SDK's
    /// `enum(u6)` status enum; null when the provider cannot read it for this
    /// actor.
    pub fn hasStatus(self: *const Actor, s: anytype) ?bool { _ = self; _ = s; return undefined; }
    /// Newest history sample at or before `time_ms`; otherwise the live
    /// pose with `velocity` taken from this struct's `velocity` field.
    pub fn transformAt(self: *const Actor, time_ms: f32) Transform { _ = self; _ = time_ms; return undefined; }
};
