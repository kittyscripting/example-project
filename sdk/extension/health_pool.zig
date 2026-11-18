pub const HealthPoolKind = enum(u8) {
    normal,
    /// Damage-absorbing armor.
    armor,
    /// Regenerating shield.
    shield,
    /// Temporary health above the maximum.
    overhealth,
};

pub const HealthPool = struct {
    kind: HealthPoolKind,
    current: f32,
    max: f32,
};

/// Health pools of one entity, in no particular order. `pools` stays valid
/// until the next tick.
pub const HealthPools = struct {
    pools: []HealthPool,
    pub fn ofKind(self: HealthPools, kind: HealthPoolKind) ?HealthPool { _ = self; _ = kind; return undefined; }
};
