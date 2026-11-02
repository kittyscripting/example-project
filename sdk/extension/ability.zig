const GameButton = @import("input.zig").GameButton;
const EffectTarget = @import("gun.zig").EffectTarget;

/// Recharge model of an ability slot.
pub const AbilityKind = enum {
    /// Recharges on a cooldown timer.
    cooldown,
    /// Recharges by accumulating points up to `max_points`.
    charged,
    /// Available while active.
    passive,
};

/// Assist class of an ability slot:
/// - `.flick`: single-shot assisted cast.
/// - `.none` (default): no assist class; `cast_time` is still reported.
pub const AbilityType = enum {
    flick,
    none,
};

/// State of one ability slot.
pub const Ability = struct {
    kind: AbilityKind = .cooldown,
    ability_type: AbilityType = .none,
    effect_target: EffectTarget = .enemy,
    button: GameButton = .ability1,
    /// Affects an area rather than a single target.
    aoe: bool = false,
    /// Meters per second; 0 means no travel time.
    projectile_speed: f32 = 0,
    /// Meters per second squared, applied along -y.
    projectile_gravity: f32 = 0,
    /// Radians the launch direction is pitched above the aim direction.
    projectile_launch_angle: f32 = 0,
    /// Health per fully charged direct hit on a non-critical hitbox, with the
    /// caster's damage bonuses and before falloff, critical multiplier, and
    /// the target's armor or damage modifiers; 0 means unknown.
    damage: f32 = 0,
    /// Factor applied to `damage` on a critical hitbox; 0 means unknown.
    critical_multiplier: f32 = 0,
    /// Seconds from start to execution; 0 is instant.
    cast_time: f32 = 0,
    /// Seconds after use before the slot may be used again.
    custom_delay: f32 = 0,
    /// Currently executing.
    active: bool = false,
    /// Whether the slot is usable this tick.
    enabled: bool = false,
    /// Currently being used.
    using: bool = false,
    charges: i32 = 0,
    /// 0 for single-charge abilities.
    max_charges: i32 = 0,
    /// Cooldown length in seconds.
    cooldown: f32 = 0,
    /// Simulation time in seconds at which the current cooldown began.
    cooldown_start: f32 = 0,
    /// Charge points of a `.charged` ability.
    points: f32 = 0,
    /// Points a `.charged` ability needs to be ready.
    max_points: f32 = 0,
    pub fn isMultiCharge(self: Ability) bool { _ = self; return undefined; }
    /// Simulation time in seconds at which the current cooldown ends.
    pub fn readyAt(self: Ability) f32 { _ = self; return undefined; }
    /// Readiness in `[0, 1]`, where 1 is ready:
    /// - `.cooldown`: progress through the cooldown window.
    /// - `.charged`: `points / max_points`.
    /// - `.passive`: 1 while active, otherwise 0.
    pub fn readyPercent(self: Ability) f32 { _ = self; return undefined; }
    /// Whether the ability can be used now:
    /// - `.cooldown`: multi-charge with a charge left; otherwise off
    /// cooldown. A multi-charge `cooldown` times the next charge.
    /// - `.charged`: `points >= max_points`.
    /// - `.passive`: active.
    pub fn canUse(self: Ability) bool { _ = self; return undefined; }
};
