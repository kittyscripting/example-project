//! 24 — Slot overrides
//!
//! Providers publish `Actor.guns`/`Actor.abilities` and rewrite every slot
//! field each tick, so a value a module writes into a slot is replaced on the
//! next tick and never changes the app. This module instead reads the provider
//! slot as input and builds a module-local effective slot where each setting
//! either inherits the provider value or replaces it; only this module's
//! target selection, shot lead, and readout use the effective values.

const sdk = @import("sdk");
const targeting = sdk.helpers.target;

const Settings = sdk.Settings("Slot Overrides", struct {
    enabled: bool = true,
    aim_type: u32 = 0,
    override_speed: bool = false,
    projectile_speed: f32 = 60.0,
    override_gravity: bool = false,
    projectile_gravity: f32 = 0.0,
    effect_target: u32 = 0,
    max_range: f32 = 0.0,
    fov: f32 = 25.0,
}, .{
    .enabled = .{ .display_name = "Enabled" },
    .aim_type = .{ .display_name = "aim Type", .control = "multi", .options = .{ "provider", "flick", "track", "bow", "none" } },
    .override_speed = .{ .display_name = "Override Projectile Speed" },
    .projectile_speed = .{ .display_name = "Projectile Speed (m/s)", .control = "slider", .min = 0.0, .max = 300.0 },
    .override_gravity = .{ .display_name = "Override Projectile Gravity" },
    .projectile_gravity = .{ .display_name = "Projectile Gravity (m/s^2)", .control = "slider", .min = 0.0, .max = 50.0 },
    .effect_target = .{ .display_name = "Effect Target", .control = "multi", .options = .{ "provider", "enemy", "ally", "both" } },
    .max_range = .{ .display_name = "Max Range (m)", .control = "slider", .min = 0.0, .max = 200.0 },
    .fov = .{ .display_name = "FOV (deg)", .control = "slider", .min = 1.0, .max = 170.0 },
});

/// Setting option index to slot value; `null` inherits the provider value.
const AIM_TYPES = [_]?sdk.AimType{ null, .flick, .track, .bow, .none };
const EFFECT_TARGETS = [_]?sdk.EffectTarget{ null, .enemy, .ally, .both };

/// The provider slot next to the values this module uses for it.
const Slot = struct {
    provider: sdk.Gun,
    aim_type: sdk.AimType,
    speed: f32,
    gravity: f32,
    effect_target: sdk.EffectTarget,
    max_range: f32,

    fn init(gun: sdk.Gun) Slot {
        const data = Settings.data;
        return .{
            .provider = gun,
            .aim_type = AIM_TYPES[@min(@as(usize, data.aim_type), AIM_TYPES.len - 1)] orelse gun.aim_type,
            .speed = if (data.override_speed) data.projectile_speed else gun.projectile_speed,
            .gravity = if (data.override_gravity) data.projectile_gravity else gun.projectile_gravity,
            .effect_target = EFFECT_TARGETS[@min(@as(usize, data.effect_target), EFFECT_TARGETS.len - 1)] orelse gun.effect_target,
            // 0 on either side means no cap; the tighter cap wins.
            .max_range = targeting.combineMaxRange(gun.max_range, data.max_range),
        };
    }

    /// Forcing a type makes a provider `.none` slot eligible; forcing `.none`
    /// drops an eligible one.
    fn handles(self: *const Slot) bool {
        return self.aim_type != .none;
    }
};

fn pickSlot(local: *const sdk.LocalActor) ?Slot {
    var it = local.enabledGuns();
    while (it.next()) |gun| {
        const slot = Slot.init(gun.*);
        if (slot.handles()) return slot;
    }
    return null;
}

const TEXT = sdk.rgba(226, 226, 226, 255);
const MUTED = sdk.rgba(150, 155, 165, 255);
const MARK = sdk.rgba(255, 205, 90, 255);

/// Lock, grace, and debounce timers.
var tracker: targeting.TargetTracker = .{};

/// One readout row: mark, label, provider value, effective value.
fn row(y: f32, name: []const u8, overridden: bool, provider: []const u8, effective: []const u8) void {
    if (overridden) sdk.render.drawText("*", 21.0, y, 12.0, MARK);
    sdk.render.drawText(name, 31.0, y, 12.0, TEXT);
    sdk.render.drawText(provider, 88.0, y, 12.0, MUTED);
    sdk.render.drawText(effective, 176.0, y, 12.0, if (overridden) MARK else TEXT);
}

fn rowFmt(y: f32, name: []const u8, overridden: bool, comptime fmt: []const u8, provider: f32, effective: f32) void {
    if (overridden) sdk.render.drawText("*", 21.0, y, 12.0, MARK);
    sdk.render.drawText(name, 31.0, y, 12.0, TEXT);
    sdk.render.drawTextFmt(fmt, .{provider}, 88.0, y, 12.0, MUTED);
    sdk.render.drawTextFmt(fmt, .{effective}, 176.0, y, 12.0, if (overridden) MARK else TEXT);
}

fn drawPanel(slot: Slot) void {
    sdk.render.drawFilledRect(12.0, 12.0, 268.0, 118.0, sdk.rgba(0, 0, 0, 175));
    sdk.render.drawText("slot overrides", 21.0, 22.0, 12.0, TEXT);
    sdk.render.drawText("provider", 88.0, 38.0, 11.0, MUTED);
    sdk.render.drawText("effective", 176.0, 38.0, 11.0, MUTED);

    var y: f32 = 54.0;
    row(y, "type", slot.aim_type != slot.provider.aim_type, @tagName(slot.provider.aim_type), @tagName(slot.aim_type));
    y += 15.0;
    rowFmt(y, "speed", slot.speed != slot.provider.projectile_speed, "{d:.0} m/s", slot.provider.projectile_speed, slot.speed);
    y += 15.0;
    rowFmt(y, "gravity", slot.gravity != slot.provider.projectile_gravity, "{d:.0}", slot.provider.projectile_gravity, slot.gravity);
    y += 15.0;
    row(y, "effect", slot.effect_target != slot.provider.effect_target, @tagName(slot.provider.effect_target), @tagName(slot.effect_target));
    y += 15.0;
    rowFmt(y, "range", slot.max_range != slot.provider.max_range, "{d:.0} m", slot.provider.max_range, slot.max_range);
}

export fn onFrame(_: f32, _: i32) void {
    if (!Settings.data.enabled) return;

    const local = sdk.localActor() orelse return;
    const avatar = local.avatar orelse return;
    const vp = sdk.render.viewport();
    if (vp.x <= 0.0 or vp.y <= 0.0) return;

    const slot = pickSlot(local) orelse {
        tracker.reset();
        sdk.render.drawTextCentered("no slot with an assist type", vp.x * 0.5, vp.y * 0.5, 12.0, MUTED);
        return;
    };
    drawPanel(slot);

    if (!sdk.camera.active()) return;

    const ctx = targeting.TargetCtx{
        .fov_deg = Settings.data.fov,
        .hitbox = .defined,
        .score = .fitts,
        .max_range = slot.max_range,
        .effect_target = slot.effect_target,
        .owned_target_def = slot.provider.owned_target_def,
    };
    const target = tracker.step(sdk.actors(), local, ctx, sdk.tickTime() * 1000.0);
    if (!target.is_valid) {
        sdk.render.drawTextCentered("no target", vp.x * 0.5, vp.y * 0.5, 12.0, MUTED);
        return;
    }

    // Lead with the effective projectile, not the provider's.
    const raw = target.aim_point;
    const led = if (slot.speed > 0.0) sdk.prediction.refine(target.actor, raw, slot.speed, slot.gravity, slot.provider.projectile_launch_angle) else raw;

    const raw_screen = sdk.camera.w2s(raw);
    if (raw_screen) |p| sdk.render.drawCircle(p.x, p.y, 4.0, sdk.rgba(120, 200, 255, 220), true);

    const p = sdk.camera.w2s(led) orelse return;
    const shade = sdk.rgba(90, 255, 130, 235);
    sdk.render.drawCircle(p.x, p.y, 9.0, shade, false);
    sdk.render.drawLine(p.x - 12.0, p.y, p.x + 12.0, p.y, shade);
    sdk.render.drawLine(p.x, p.y - 12.0, p.x, p.y + 12.0, shade);
    if (raw_screen) |r| sdk.render.drawLine(r.x, r.y, p.x, p.y, sdk.rgba(255, 220, 120, 220));

    sdk.render.drawTextFmt("id {d}  {d:.0}m", .{
        target.actor.id,
        avatar.transform.position.dist(target.actor.transform.position),
    }, p.x + 14.0, p.y + 8.0, 11.0, sdk.rgba(230, 230, 230, 255));
}
