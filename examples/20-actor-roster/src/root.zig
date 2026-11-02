//! 20 — Actor roster (per-actor settings)
//!
//! Declares the actor types a module supports with `sdk.ActorList`. Each
//! entry is an id plus a user-facing name; ids must be non-zero and unique,
//! names 1 to 64 bytes. An unreferenced `ActorList` is dropped, so keep a use
//! of `.count` around. `Settings` values are then stored per listed actor
//! type; `.data` holds the values for the type of the active actor.

const sdk = @import("sdk");

const ENTRIES = [_]sdk.ActorListEntry{
    .{ .id = 0x1001, .name = "Sample Actor One" },
    .{ .id = 0x1002, .name = "Sample Actor Two" },
    .{ .id = 0x1003, .name = "Sample Actor Three" },
};

const Roster = sdk.ActorList(&ENTRIES);

const Settings = sdk.Settings("Per-Actor Demo", struct {
    enabled: bool = true,
    show_label: bool = true,
}, .{
    .enabled = .{ .display_name = "Enabled" },
    .show_label = .{ .display_name = "Show Active Actor Label" },
});

fn nameFor(type_id: u64) ?[]const u8 {
    for (ENTRIES) |entry| {
        if (entry.id == type_id) return entry.name;
    }
    return null;
}

export fn onLoad() void {
    sdk.info("roster: {d} actor types declared", .{Roster.count});
}

export fn onFrame(_: f32, _: i32) void {
    if (!Settings.data.enabled) return;

    const vp = sdk.render.viewport();
    if (vp.x <= 0.0 or vp.y <= 0.0) return;

    sdk.render.drawFilledRect(12.0, 12.0, 360.0, 66.0, sdk.rgba(0, 0, 0, 175));
    sdk.render.drawText("Per-actor settings demo", 22.0, 22.0, 13.0, sdk.rgba(255, 255, 255, 255));
    sdk.render.drawTextFmt("roster: {d} types declared", .{Roster.count}, 22.0, 58.0, 11.0, sdk.rgba(170, 170, 170, 255));

    if (!Settings.data.show_label) return;
    const avatar = (sdk.localActor() orelse return).avatar orelse return;
    const name = nameFor(avatar.type_id) orelse "unlisted actor type";

    sdk.render.drawTextFmt("active actor: {s}  (type 0x{X})", .{ name, avatar.type_id }, 22.0, 42.0, 12.0, sdk.rgba(190, 220, 255, 255));
}
