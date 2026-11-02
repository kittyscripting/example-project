const runtime = @import("runtime");
const Actor = @import("actor.zig").Actor;
const Gun = @import("gun.zig").Gun;
const Ability = @import("ability.zig").Ability;
const AimSlotRef = @import("helpers/slots.zig").AimSlotRef;
const input = @import("input.zig");
pub const GameButton = input.GameButton;
pub const DesireSentinel = input.DesireSentinel;

pub const EnabledGunIter = struct {
    pub fn next(self: *EnabledGunIter) ?*Gun { _ = self; return undefined; }
};

pub const EnabledAbilityIter = struct {
    pub fn next(self: *EnabledAbilityIter) ?*Ability { _ = self; return undefined; }
};

/// Enabled slots with aim behavior: gun `aim_type != .none` or
/// ability `ability_type != .none`, guns first, then abilities.
pub const EnabledAimSlotIter = struct {
    pub fn next(self: *EnabledAimSlotIter) ?AimSlotRef { _ = self; return undefined; }
};

/// The local player's actor and its input/view state, refreshed each tick.
/// Setters request hold state for the current tick; `isPressed` and
/// `last_view_direction` report what is in effect.
pub const LocalActor = extern struct {
    /// Entity controlling the local player; may differ from `avatar`.
    controller: ?*Actor,
    /// In-world character the local player controls.
    avatar: ?*Actor,
    /// Unit vector: the view as last read, before this tick's mouse rotation.
    /// Plan `setViewDir` writes from this; the player's mouse rotation is
    /// added on top of a written view.
    last_view_direction: runtime.Vec3,
    /// Whether `button` is held.
    pub fn isPressed(self: *const LocalActor, button: GameButton) bool { _ = self; _ = button; return undefined; }
    /// Request `button` held (`down = true`) or released for the current
    /// tick.
    pub fn setPressed(self: *LocalActor, button: GameButton, down: bool) void { _ = self; _ = button; _ = down; }
    /// Drop the request for `button`, clearing any hold set by `setPressed`.
    pub fn releaseButton(self: *LocalActor, button: GameButton) void { _ = self; _ = button; }
    /// Request a view direction for the current tick; `dir` need not be
    /// normalized.
    pub fn setViewDir(self: *LocalActor, dir: runtime.Vec3) void { _ = self; _ = dir; }
    /// The view the command sent this tick carries unless a module sets one:
    /// `last_view_direction` turned by this tick's mouse rotation. It is the
    /// angle of the next command when `sdk.isNextFrameLogic()`.
    pub fn viewDirection(self: *const LocalActor) runtime.Vec3 { _ = self; return undefined; }
    pub fn firstEnabledGun(self: *const LocalActor) ?*Gun { _ = self; return undefined; }
    pub fn enabledGuns(self: *const LocalActor) EnabledGunIter { _ = self; return undefined; }
    pub fn firstEnabledAbility(self: *const LocalActor) ?*Ability { _ = self; return undefined; }
    pub fn enabledAbilities(self: *const LocalActor) EnabledAbilityIter { _ = self; return undefined; }
    pub fn enabledAimSlots(self: *const LocalActor) EnabledAimSlotIter { _ = self; return undefined; }
};

/// Resolve a keybind setting against live input:
/// - `0xFFFF_FFFF` (Default): the `fallback` button.
/// - `0`: unbound; never down.
/// - otherwise: a key or mouse VK code.
pub fn isKeyOrGameButtonDown(local: *const LocalActor, setting: u32, fallback: GameButton) bool { _ = local; _ = setting; _ = fallback; return undefined; }
