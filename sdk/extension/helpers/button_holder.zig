const LocalActor = @import("../local_actor.zig").LocalActor;
const GameButton = @import("../input.zig").GameButton;
const EffectTarget = @import("../gun.zig").EffectTarget;
const slots = @import("slots.zig");

/// One button a module drives; selecting another releases the previous one.
pub const ButtonHolder = struct {
    held: ?GameButton = null,
    /// Hold `button` down this update; a different held button is released.
    pub fn holdDown(self: *ButtonHolder, local: *LocalActor, button: GameButton) void { _ = self; _ = local; _ = button; }
    /// Track `button` and keep it up this update; a different held button is
    /// released.
    pub fn holdUp(self: *ButtonHolder, local: *LocalActor, button: GameButton) void { _ = self; _ = local; _ = button; }
    /// Button up this update; `held` is unchanged.
    pub fn pressUp(self: *ButtonHolder, local: *LocalActor) void { _ = self; _ = local; }
    /// Release the tracked button and forget it.
    pub fn release(self: *ButtonHolder, local: *LocalActor) void { _ = self; _ = local; }
};

/// The engaged slot's fire button held together with its twin's.
pub const TwinFire = struct {
    /// Hold the engaged slot's button, plus the twin's while the player holds
    /// it.
    pub fn hold(self: *TwinFire, local: *LocalActor, slot: slots.AimSlotRef, effect_target: EffectTarget) void { _ = self; _ = local; _ = slot; _ = effect_target; }
    /// Release both tracked buttons and forget them.
    pub fn release(self: *TwinFire, local: *LocalActor) void { _ = self; _ = local; }
};

/// Button of `slot`'s twin: an enabled `.track` gun on another button the
/// player holds, with the same ballistics and an effect target covering
/// `effect_target`'s side. Null when `slot` is not a `.track` gun or no twin is
/// held.
pub fn twinButton(local: *LocalActor, slot: slots.AimSlotRef, effect_target: EffectTarget) ?GameButton { _ = local; _ = slot; _ = effect_target; return undefined; }
