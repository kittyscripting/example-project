//! 15 — Local actor and guns
//!
//! A panel over `sdk.localActor()`: avatar, view angles, health, and every
//! enabled gun and ability slot with its readiness. Slot iterators skip
//! disabled slots; `avatar.guns` and `avatar.abilities` hold all of them.
//! Cooldowns are seconds of `sdk.tickTime()`.

const sdk = @import("sdk");

const Settings = sdk.Settings("Local Actor", struct {
    enabled: bool = true,
    show_guns: bool = true,
    show_abilities: bool = true,
    max_rows: u32 = 8,
}, .{
    .enabled = .{ .display_name = "Enabled" },
    .show_guns = .{ .display_name = "Show Weapons" },
    .show_abilities = .{ .display_name = "Show Abilities" },
    .max_rows = .{ .display_name = "Max Rows", .control = "slider", .min = 1, .max = 20 },
});

const TEXT = sdk.rgba(225, 225, 225, 255);

fn row(y: f32, comptime fmt: []const u8, args: anytype) void {
    sdk.render.drawTextFmt(fmt, args, 20.0, y, 12.0, TEXT);
}

fn bar(y: f32, fraction: f32, shade: i32) void {
    const w = 260.0;
    sdk.render.drawFilledRect(20.0, y, w, 4.0, sdk.rgba(45, 50, 60, 255));
    sdk.render.drawFilledRect(20.0, y, w * sdk.clampf(fraction, 0.0, 1.0), 4.0, shade);
}

fn listEnded(y: *f32, shown: u32) void {
    if (shown == 0) {
        row(y.*, "  (none enabled)", .{});
        y.* += 14.0;
    }
}

export fn onFrame(_: f32, _: i32) void {
    if (!Settings.data.enabled) return;

    const local = sdk.localActor() orelse return;
    const avatar = local.avatar orelse return;

    const now = sdk.tickTime();
    const heading = sdk.util.math.yawPitch(local.last_view_direction);

    sdk.render.drawFilledRect(12.0, 12.0, 290.0, 300.0, sdk.rgba(0, 0, 0, 180));

    var y: f32 = 24.0;
    row(y, "avatar id {d}  team {s}", .{ avatar.id, @tagName(avatar.team) });
    y += 16.0;
    row(y, "health {d:.0} / {d:.0}", .{ avatar.health, avatar.max_health });
    y += 16.0;
    row(y, "view yaw {d:.1}  pitch {d:.1} deg", .{ heading.x * sdk.util.math.rad_to_deg, heading.y * sdk.util.math.rad_to_deg });
    y += 16.0;
    row(y, "slots: {d} weapons, {d} abilities", .{ avatar.guns.len, avatar.abilities.len });
    y += 20.0;

    if (Settings.data.show_guns) {
        row(y, "weapons", .{});
        y += 16.0;
        var it = local.enabledGuns();
        var shown: u32 = 0;
        while (it.next()) |gun| {
            if (shown >= Settings.data.max_rows) break;
            shown += 1;

            const remaining = @max(0.0, gun.cooldown_start + gun.cooldown - now);
            const ready = if (gun.cooldown > 0.0) 1.0 - remaining / gun.cooldown else 1.0;
            row(y, "  {s} [{s}]  ammo {d}/{d}{s}{s}", .{
                @tagName(gun.kind),
                @tagName(gun.button),
                gun.ammo,
                gun.max_ammo,
                if (gun.reloading) "  reloading" else "",
                if (gun.charging) "  charging" else "",
            });
            y += 14.0;
            bar(y, ready, sdk.rgba(120, 200, 255, 255));
            y += 10.0;
        }
        listEnded(&y, shown);
        y += 6.0;
    }

    if (Settings.data.show_abilities) {
        row(y, "abilities", .{});
        y += 16.0;
        var it = local.enabledAbilities();
        var shown: u32 = 0;
        while (it.next()) |ability| {
            if (shown >= Settings.data.max_rows) break;
            shown += 1;

            const ready = ability.readyPercent();
            row(y, "  {s} [{s}]  {s}{s}  {d:.0}%", .{
                @tagName(ability.kind),
                @tagName(ability.button),
                if (ability.canUse()) "ready" else "charging",
                if (ability.isMultiCharge()) " multicharge" else "",
                ready * 100.0,
            });
            y += 14.0;
            bar(y, ready, sdk.rgba(255, 190, 90, 255));
            y += 10.0;
        }
        listEnded(&y, shown);
    }
}
