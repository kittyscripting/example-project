const runtime = @import("runtime");
const AimSlotRef = @import("slots.zig").AimSlotRef;
const Actor = @import("../actor.zig").Actor;
const Vec3 = runtime.Vec3;

/// Health one direct hit removes: `charge * damage`, times
/// `critical_multiplier` on a critical hitbox. A `critical_multiplier` of 0
/// (unknown) counts as 1.
pub fn shotDamage(damage: f32, critical_multiplier: f32, charge: f32, critical: bool) f32 { _ = damage; _ = critical_multiplier; _ = charge; _ = critical; return undefined; }

/// Whether a hit of `shotDamage(damage, critical_multiplier, charge,
/// critical)` removes `health`. Unknown damage or health (0 or less) counts as
/// a kill.
pub fn kills(damage: f32, critical_multiplier: f32, charge: f32, critical: bool, health: f32) bool { _ = damage; _ = critical_multiplier; _ = charge; _ = critical; _ = health; return undefined; }

/// `kills` for a direct hit of `slot` on `actor` along the ray from
/// `ray_start` in `ray_dir`. The hit is critical when the ray hits one of the
/// actor's critical hitboxes, with `lead` and `scale` as in
/// `hitboxes.rayHitsHitboxes`. Allies count as killed: they are healed, not
/// damaged.
pub fn rayKills(slot: AimSlotRef, actor: *const Actor, ray_start: Vec3, ray_dir: Vec3, lead: Vec3, scale: f32) bool { _ = slot; _ = actor; _ = ray_start; _ = ray_dir; _ = lead; _ = scale; return undefined; }
