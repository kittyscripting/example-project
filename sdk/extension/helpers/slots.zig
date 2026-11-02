const Gun = @import("../gun.zig").Gun;
const GunKind = @import("../gun.zig").GunKind;
const EffectTarget = @import("../gun.zig").EffectTarget;
const Ability = @import("../ability.zig").Ability;
const GameButton = @import("../input.zig").GameButton;

pub const LatchKind = enum {
    /// A slot was tracked and none is current now.
    lost,
    /// The current slot differs from the tracked one, or tracking started.
    swapped,
    /// The current slot is the tracked one, or neither exists.
    held,
};

/// Tracks the index of the enabled slot. Call `observe` once per update with
/// the enabled index, or null when none is enabled.
pub const EnabledLatch = struct {
    pub fn observe(self: *EnabledLatch, current_slot: ?u8) LatchKind { _ = self; _ = current_slot; return undefined; }
    pub fn reset(self: *EnabledLatch) void { _ = self; }
};

/// Tracks a gun by pointer identity, e.g. `LocalActor.firstEnabledGun()`.
pub const GunLatch = struct {
    pub fn observe(self: *GunLatch, current: ?*const Gun) LatchKind { _ = self; _ = current; return undefined; }
    pub fn reset(self: *GunLatch) void { _ = self; }
};

/// Gun or ability slot.
pub const AimSlotRef = union(enum) {
    gun: *Gun,
    ability: *Ability,
    pub fn isFlick(self: AimSlotRef) bool { _ = self; return undefined; }
    pub fn isTrack(self: AimSlotRef) bool { _ = self; return undefined; }
    pub fn isBow(self: AimSlotRef) bool { _ = self; return undefined; }
    pub fn isNone(self: AimSlotRef) bool { _ = self; return undefined; }
    pub fn button(self: AimSlotRef) GameButton { _ = self; return undefined; }
    pub fn projectileSpeed(self: AimSlotRef) f32 { _ = self; return undefined; }
    pub fn projectileGravity(self: AimSlotRef) f32 { _ = self; return undefined; }
    pub fn projectileLaunchAngle(self: AimSlotRef) f32 { _ = self; return undefined; }
    pub fn maxRange(self: AimSlotRef) f32 { _ = self; return undefined; }
    /// Health one direct hit removes at full charge; 0 means unknown.
    pub fn damage(self: AimSlotRef) f32 { _ = self; return undefined; }
    /// Factor applied to `damage` on a critical hitbox; 0 means unknown.
    pub fn criticalMultiplier(self: AimSlotRef) f32 { _ = self; return undefined; }
    /// Fraction of `damage` a shot released now deals: the charge progress of
    /// a charging gun, else 1.
    pub fn shotCharge(self: AimSlotRef) f32 { _ = self; return undefined; }
    pub fn cooldown(self: AimSlotRef) f32 { _ = self; return undefined; }
    pub fn cooldownStart(self: AimSlotRef) f32 { _ = self; return undefined; }
    pub fn effectTarget(self: AimSlotRef) EffectTarget { _ = self; return undefined; }
    pub fn ownedTargetDef(self: AimSlotRef) u64 { _ = self; return undefined; }
    pub fn kind(self: AimSlotRef) GunKind { _ = self; return undefined; }
    /// Same variant and same slot pointer.
    pub fn ptrEquals(self: AimSlotRef, other: AimSlotRef) bool { _ = self; _ = other; return undefined; }
};

/// `GunLatch` for `AimSlotRef`, so gun and ability slots share one signal.
pub const AimSlotLatch = struct {
    pub fn observe(self: *AimSlotLatch, current: ?AimSlotRef) LatchKind { _ = self; _ = current; return undefined; }
    pub fn reset(self: *AimSlotLatch) void { _ = self; }
};
