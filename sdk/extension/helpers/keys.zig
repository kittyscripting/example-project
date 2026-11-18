const local_actor = @import("../local_actor.zig");
const LocalActor = local_actor.LocalActor;
const EffectTarget = @import("../gun.zig").EffectTarget;
const slots = @import("slots.zig");

/// Side `slot` engages for a primary `key` and an `ally_key` setting
/// (`isKeyOrGameButtonDown` values, with the slot's button as Default), as
/// `target.keyedEffectTarget`. Neither key engages the slot while the player
/// fires the other weapon (`target.firesOtherWeapon`): a custom key is down
/// for every slot at once, and the held fire button picks the weapon.
pub fn effectTarget(local: *const LocalActor, slot: slots.AimSlotRef, key: u32, ally_key: u32) ?EffectTarget { _ = local; _ = slot; _ = key; _ = ally_key; return undefined; }
