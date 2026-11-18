/// Statuses an actor can carry; the tag is the bit index in `Actor.status`
/// and `Actor.status_known`.
pub const Status = enum(u6) {
    discorded = 0,
    harmony = 1,
    anti_healed = 2,
    slept = 3,
    incapacitated = 4,
};

/// Keys of `Actor.stats`. `value` is an additive fraction: the effective
/// value is `base × (1 + value)`, and 0 is the base.
pub const Stat = enum(u32) {
    damage_dealt_bonus = 0,
    projectile_speed_bonus = 1,
};
