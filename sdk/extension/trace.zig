const runtime = @import("runtime");

/// What a trace may hit. World bits stand alone; an entity can block only
/// when both its class bit and its relationship bit are set. Which bits are
/// honored depends on the active title; each result reports them in
/// `TraceHit.evaluated`. Unset or unevaluated bits never block.
pub const TraceMask = packed struct(u64) {
    /// Static world collision geometry.
    geometry: bool = false,
    _world_reserved: u7 = 0,
    /// `ActorKind.player` actors.
    players: bool = false,
    /// `ActorKind.turret` actors.
    turrets: bool = false,
    /// `ActorKind.explosive` actors.
    explosives: bool = false,
    /// `ActorKind.support` actors.
    supports: bool = false,
    /// `ActorKind.unknown` actors.
    unknown_kind: bool = false,
    /// Scene props.
    props: bool = false,
    _class_reserved: u10 = 0,
    /// The local actor.
    self: bool = false,
    /// `Team.ally` entities other than the local actor.
    allies: bool = false,
    /// `Team.enemy` entities.
    enemies: bool = false,
    /// `Team.neutral` entities.
    neutral: bool = false,
    /// `Team.unknown` entities.
    unknown_team: bool = false,
    _relation_reserved: u3 = 0,
    _reserved: u32 = 0,
    /// World geometry only.
    pub const world: TraceMask = .{ .geometry = true };
    /// Every defined bit.
    pub const everything: TraceMask = .{
            .geometry = true,
            .players = true,
            .turrets = true,
            .explosives = true,
            .supports = true,
            .unknown_kind = true,
            .props = true,
            .self = true,
            .allies = true,
            .enemies = true,
            .neutral = true,
            .unknown_team = true,
        };
};

pub const TraceHit = struct {
    /// Obstacle position in meters, or the ray end when nothing was hit.
    position: runtime.Vec3,
    /// Hit entity id; -1 for geometry hits and misses.
    entity: i32,
    /// True when something selected by the mask blocked the segment.
    hit: bool,
    /// Requested bits actually tested for this call. A clear result only
    /// covers these bits; zero means nothing was tested.
    evaluated: TraceMask = .{},
};

/// Cast a segment between two world points in meters against what `mask`
/// selects, skipping the actor with id `ignore_actor_id` (-1 skips none).
/// Without collision support nothing is tested and the segment is clear.
pub fn trace(from: runtime.Vec3, to: runtime.Vec3, ignore_actor_id: i32, mask: TraceMask) TraceHit { _ = from; _ = to; _ = ignore_actor_id; _ = mask; return undefined; }
