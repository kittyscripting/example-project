//! 25 — Hero slot overrides (`overwatch`)
//!
//! A provider publishes `Actor.guns`/`Actor.abilities` and restamps every
//! declared slot field each tick, so writing through `avatar.guns[i]` is lost
//! on the next tick and never reaches the app. This module instead reads the
//! live slot as input, resolves an effective slot from the per-hero settings
//! below, and feeds that into its own target selection and projectile lead.
//! Values are stored per hero type, keyed by the actor roster the provider
//! already registers, and only change this module's behavior.

const sdk = @import("sdk");
const app = @import("overwatch");
const targeting = sdk.helpers.target;

const Settings = sdk.Settings("Hero Slot Overrides", struct {
    enabled: bool = true,
    override_speed: bool = false,
    projectile_speed: f32 = 150.0,
    aim_type: u32 = 0,
    max_range: f32 = 0.0,
}, .{
    .enabled = .{ .display_name = "Enabled" },
    .override_speed = .{ .display_name = "Override Projectile Speed" },
    .projectile_speed = .{ .display_name = "Projectile Speed (m/s)", .control = "slider", .min = 0.0, .max = 400.0 },
    .aim_type = .{
        .display_name = "Aim Type",
        .control = "multi",
        .options = .{ "declared", "flick", "track", "bow", "none" },
    },
    .max_range = .{ .display_name = "Range Cap (m, 0 = declared)", .control = "slider", .min = 0.0, .max = 200.0 },
});

/// `aim_type` choices; index 0 keeps the declared value.
const AIM_CHOICES = [_]?sdk.AimType{ null, .flick, .track, .bow, .none };

/// Slot values this module acts on.
const Slot = struct {
    aim_type: sdk.AimType,
    projectile_speed: f32,
    projectile_gravity: f32,
    projectile_launch_angle: f32,
    max_range: f32,
    effect_target: sdk.EffectTarget,
};

/// Declared slot with this hero's overrides applied. A range cap only tightens
/// the declared one; 0 is unlimited on either side.
fn effectiveSlot(declared: *const sdk.Gun) Slot {
    const choice = AIM_CHOICES[@min(@as(usize, Settings.data.aim_type), AIM_CHOICES.len - 1)];
    return .{
        .aim_type = choice orelse declared.aim_type,
        .projectile_speed = if (Settings.data.override_speed) Settings.data.projectile_speed else declared.projectile_speed,
        .projectile_gravity = declared.projectile_gravity,
        .projectile_launch_angle = declared.projectile_launch_angle,
        .max_range = targeting.combineMaxRange(declared.max_range, Settings.data.max_range),
        .effect_target = declared.effect_target,
    };
}

const TEXT = sdk.rgba(225, 225, 225, 255);
const DIM = sdk.rgba(165, 165, 165, 255);
const ACCENT = sdk.rgba(190, 220, 255, 255);

var tracker: targeting.TargetTracker = .{};

fn row(y: f32, shade: i32, comptime fmt: []const u8, args: anytype) void {
    sdk.render.drawTextFmt(fmt, args, 20.0, y, 12.0, shade);
}

/// Display name of a hero this module knows; the `overwatch` actor `eq`
/// predicates say which ids are which hero.
fn heroName(id: u64) ?[]const u8 {
    if (app.actor.freja.eq(id)) return "Freja";
    if (app.actor.sierra.eq(id)) return "Sierra";
    if (app.actor.mizuki.eq(id)) return "Mizuki";
    if (app.actor.wuyang.eq(id)) return "Wuyang";
    return null;
}

export fn onFrame(_: f32, _: i32) void {
    if (!Settings.data.enabled) return;
    const vp = sdk.render.viewport();
    if (vp.x <= 0.0 or vp.y <= 0.0) return;
    const local = sdk.localActor() orelse return;
    const avatar = local.avatar orelse return;

    const hero_name = heroName(avatar.type_id) orelse "unlisted hero";

    sdk.render.drawFilledRect(12.0, 12.0, 340.0, 92.0, sdk.rgba(0, 0, 0, 175));
    var y: f32 = 22.0;
    row(y, ACCENT, "{s}", .{hero_name});
    y += 16.0;

    const declared = local.firstEnabledGun() orelse {
        row(y, DIM, "no enabled weapon slot", .{});
        return;
    };
    const eff = effectiveSlot(declared);

    row(y, DIM, "declared   {s}  {d:.0} m/s  g{d:.0}  r{d:.0}", .{
        @tagName(declared.aim_type),
        declared.projectile_speed,
        declared.projectile_gravity,
        declared.max_range,
    });
    y += 16.0;
    row(y, TEXT, "effective  {s}  {d:.0} m/s  g{d:.0}  r{d:.0}", .{
        @tagName(eff.aim_type),
        eff.projectile_speed,
        eff.projectile_gravity,
        eff.max_range,
    });
    y += 16.0;
    row(y, DIM, "{s} targets; r0 = no range cap", .{@tagName(eff.effect_target)});

    if (eff.aim_type == .none or !sdk.camera.active()) return;

    const ctx = targeting.TargetCtx{
        .fov_deg = 25.0,
        .hitbox = .defined,
        .score = .fitts,
        .max_range = eff.max_range,
        .effect_target = eff.effect_target,
    };
    const target = tracker.step(sdk.actors(), local, ctx, sdk.tickTime() * 1000.0);
    if (!target.is_valid) return;

    const led = sdk.prediction.refine(target.actor, target.aim_point, eff.projectile_speed, eff.projectile_gravity, eff.projectile_launch_angle);
    const p = sdk.camera.w2s(led) orelse return;
    const shade = sdk.rgba(90, 255, 130, 235);
    sdk.render.drawCircle(p.x, p.y, 9.0, shade, false);
    sdk.render.drawLine(p.x - 12.0, p.y, p.x + 12.0, p.y, shade);
    sdk.render.drawLine(p.x, p.y - 12.0, p.x, p.y + 12.0, shade);
    sdk.render.drawTextFmt("{s}  {d:.0} m/s", .{ @tagName(eff.aim_type), eff.projectile_speed }, p.x + 14.0, p.y + 8.0, 11.0, TEXT);
}
