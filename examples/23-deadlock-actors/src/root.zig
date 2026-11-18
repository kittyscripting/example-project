//! 23 — actor kinds and projectile intercepts
//!
//! Sorts live actors with the app's public `actor` `eq` predicates (minions,
//! objectives, Soul Orbs, and haunting skulls; every other actor is a hero),
//! labels them by kind and team, counts them per kind, and draws the linear
//! intercept to the nearest enemy. Positions are SDK world meters; the
//! intercept takes a m/s velocity and projectile speed and returns `null`
//! when no intercept exists.

const sdk = @import("sdk");
const app = @import("deadlock");

const Settings = sdk.Settings("deadlock Actors", struct {
    enabled: bool = true,
    max_distance: f32 = 60.0,
    projectile_speed: f32 = 30.0,
    hero_color: u32 = 0xFFFF6B6B,
    minion_color: u32 = 0xFF7BD88F,
    objective_color: u32 = 0xFF8A8AFF,
    other_color: u32 = 0xFFFFD24A,
    intercept_color: u32 = 0xFFFFFFFF,
}, .{
    .enabled = .{ .display_name = "Enabled" },
    .max_distance = .{ .display_name = "Max Distance (m)", .control = "slider", .min = 10.0, .max = 200.0 },
    .projectile_speed = .{ .display_name = "Projectile Speed (m/s)", .control = "slider", .min = 5.0, .max = 200.0 },
    .hero_color = .{ .display_name = "Hero Color", .control = "color" },
    .minion_color = .{ .display_name = "Minion Color", .control = "color" },
    .objective_color = .{ .display_name = "Objective Color", .control = "color" },
    .other_color = .{ .display_name = "Orb / Skull Color", .control = "color" },
    .intercept_color = .{ .display_name = "Intercept Color", .control = "color" },
});

/// Color settings are `0xAARRGGBB`; draw calls take `0xAABBGGRR`.
fn drawColor(argb: u32) i32 {
    return @bitCast(sdk.util.argbToHost(argb));
}

const Kind = enum { hero, minion, objective, orb, skull };
const KIND_COUNT = @typeInfo(Kind).@"enum".fields.len;

fn kindOf(id: u64) Kind {
    if (app.actor.minion.eq(id)) return .minion;
    if (app.actor.objective.eq(id)) return .objective;
    if (app.actor.soul_orb.eq(id)) return .orb;
    if (app.actor.haunting_skull.eq(id)) return .skull;
    return .hero;
}

fn kindColor(kind: Kind) i32 {
    return drawColor(switch (kind) {
        .hero => Settings.data.hero_color,
        .minion => Settings.data.minion_color,
        .objective => Settings.data.objective_color,
        .orb, .skull => Settings.data.other_color,
    });
}

export fn onFrame(_: f32, _: i32) void {
    if (!Settings.data.enabled or !sdk.camera.active()) return;

    const vp = sdk.render.viewport();
    if (vp.x <= 0.0 or vp.y <= 0.0) return;
    const avatar = (sdk.localActor() orelse return).avatar orelse return;
    const shooter = avatar.transform.position;

    var counts = [_]u32{0} ** KIND_COUNT;
    var nearest: ?*const sdk.Actor = null;
    var nearest_distance: f32 = 0.0;

    for (sdk.actors()) |*actor| {
        if (actor.id == avatar.id) continue;
        const distance = shooter.dist(actor.transform.position);
        if (distance > Settings.data.max_distance) continue;

        const kind = kindOf(actor.type_id);
        counts[@intFromEnum(kind)] += 1;

        if (actor.team == .enemy and (nearest == null or distance < nearest_distance)) {
            nearest = actor;
            nearest_distance = distance;
        }

        const screen = sdk.camera.w2s(actor.transform.position) orelse continue;
        sdk.render.drawTextCenteredFmt("{s} ({s})  {d:.0}m", .{
            @tagName(kind),
            @tagName(actor.team),
            distance,
        }, screen.x, screen.y - 16.0, 11.0, kindColor(kind));
    }

    var intercept_time: ?f32 = null;
    if (nearest) |target| {
        const intercept = sdk.helpers.intercept.linearIntercept(
            shooter,
            target.transform.position,
            target.velocity,
            Settings.data.projectile_speed,
        );
        if (intercept) |hit| {
            intercept_time = hit.time;
            const shade = drawColor(Settings.data.intercept_color);
            if (sdk.camera.w2s(target.transform.position)) |target_screen| {
                if (sdk.camera.w2s(hit.position)) |intercept_screen| {
                    sdk.render.drawLine(target_screen.x, target_screen.y, intercept_screen.x, intercept_screen.y, shade);
                    sdk.render.drawCircle(intercept_screen.x, intercept_screen.y, 6.0, shade, false);
                    sdk.render.drawTextCenteredFmt("intercept {d:.2}s", .{hit.time}, intercept_screen.x, intercept_screen.y + 10.0, 11.0, shade);
                }
            }
        }
    }

    sdk.render.drawFilledRect(12.0, 12.0, 380.0, 64.0, sdk.rgba(0, 0, 0, 165));
    sdk.render.drawTextFmt("heroes {d}  minions {d}  objectives {d}  orbs {d}  skulls {d}", .{
        counts[@intFromEnum(Kind.hero)],
        counts[@intFromEnum(Kind.minion)],
        counts[@intFromEnum(Kind.objective)],
        counts[@intFromEnum(Kind.orb)],
        counts[@intFromEnum(Kind.skull)],
    }, 22.0, 20.0, 12.0, sdk.rgba(225, 225, 225, 255));

    if (nearest) |target| {
        if (intercept_time) |time| {
            sdk.render.drawTextFmt("nearest enemy {s} id {d}  {d:.1} m  intercept {d:.2}s", .{
                @tagName(kindOf(target.type_id)),
                target.type_id,
                nearest_distance,
                time,
            }, 22.0, 38.0, 12.0, kindColor(kindOf(target.type_id)));
        } else {
            sdk.render.drawTextFmt("nearest enemy {s} id {d}  {d:.1} m  no intercept", .{
                @tagName(kindOf(target.type_id)),
                target.type_id,
                nearest_distance,
            }, 22.0, 38.0, 12.0, kindColor(kindOf(target.type_id)));
        }
    } else {
        sdk.render.drawTextFmt("no enemy within {d:.0} m", .{
            Settings.data.max_distance,
        }, 22.0, 38.0, 12.0, sdk.rgba(200, 200, 200, 255));
    }
}
