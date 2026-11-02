const GameButton = @import("input.zig").GameButton;

/// Physical class of a weapon slot; the assist class is `AimType`.
pub const GunKind = enum {
    standard,
    /// Fired while aiming down a scope.
    scoped,
    /// Drawn; releasing fires the projectile.
    bow,
    /// Fired after a cast or wind-up.
    casted,
};

/// Assist class of a weapon slot, independent of `GunKind`:
/// - `.flick`: single-shot snap, then fire.
/// - `.track`: continuous follow while fire is held.
/// - `.bow`: holds `button` through the snap, releasing on target to fire.
/// - `.none` (default): no assist.
pub const AimType = enum {
    flick,
    track,
    bow,
    none,
};

/// Which actors a slot may target:
/// - `.enemy` (default): opponents.
/// - `.ally`: allies, e.g. a healing weapon.
/// - `.both`: opponents and allies.
pub const EffectTarget = enum {
    enemy,
    ally,
    both,
};

/// State of one weapon slot.
pub const Gun = struct {
    kind: GunKind = .standard,
    aim_type: AimType = .none,
    effect_target: EffectTarget = .enemy,
    /// Type id of an owned deployable this slot may also target when the
    /// local actor owns it; 0 disables.
    owned_target_def: u64 = 0,
    button: GameButton = .primary_fire,
    /// Affects an area rather than a single target.
    aoe: bool = false,
    /// Charges before firing.
    charging: bool = false,
    /// Meters per second; 0 means no travel time.
    projectile_speed: f32 = 0,
    /// Meters per second squared, applied along -y.
    projectile_gravity: f32 = 0,
    /// Radians the launch direction is pitched above the aim direction.
    projectile_launch_angle: f32 = 0,
    /// Target-selection range cap in meters; 0 means none. See
    /// `helpers.target.combineMaxRange`.
    max_range: f32 = 0,
    /// Health per fully charged direct hit on a non-critical hitbox, with the
    /// shooter's damage bonuses and before falloff, critical multiplier, and
    /// the target's armor or damage modifiers; 0 means unknown.
    damage: f32 = 0,
    /// Factor applied to `damage` on a critical hitbox; 0 means unknown.
    critical_multiplier: f32 = 0,
    /// Currently firing or executing.
    active: bool = false,
    /// Charge progress in `[0, 1]` for charging weapons.
    charge_percent: f32 = 0,
    /// Whether the slot is usable this tick.
    enabled: bool = false,
    reloading: bool = false,
    ammo: i32 = 0,
    max_ammo: i32 = 0,
    /// Shot cooldown length in seconds.
    cooldown: f32 = 0,
    /// Simulation time in seconds at which the current cooldown began.
    cooldown_start: f32 = 0,
};
