//! 19 — Utility helpers
//!
//! `sdk.util.random` distributions — uniform (`sdk.random`), standard normal
//! (`normalSample`), and its CDF (`normalCdf`) — plus the text helpers
//! `containsAsciiLower` and `copyText`, and the color conversion
//! `argbToHost`. The RNG is process-wide, so `sdk.seedRandom` reseeds the
//! sequence every module draws from.

const sdk = @import("sdk");

const Settings = sdk.Settings("Util Helpers", struct {
    enabled: bool = true,
    sample_rate: u32 = 8,
}, .{
    .enabled = .{ .display_name = "Enabled" },
    .sample_rate = .{ .display_name = "Samples / Tick", .control = "slider", .min = 1, .max = 64 },
});

const BINS = 16;
const SIGMA_RANGE = 3.0;

var histogram: [BINS]u32 = [_]u32{0} ** BINS;
var sample_count: u32 = 0;

export fn onLoad() void {
    sdk.seedRandom(1337);
}

export fn onTick(_: f32, _: i32) void {
    var i: u32 = 0;
    while (i < Settings.data.sample_rate) : (i += 1) {
        const sample = sdk.util.random.normalSample();
        const normalized = sdk.clampf((sample + SIGMA_RANGE) / (2.0 * SIGMA_RANGE), 0.0, 0.999);
        const bin: usize = @intFromFloat(normalized * @as(f32, @floatFromInt(BINS)));
        histogram[bin] += 1;
        sample_count += 1;
    }
}

const TEXT = sdk.rgba(225, 225, 225, 255);

fn row(y: f32, comptime fmt: []const u8, args: anytype) void {
    sdk.render.drawTextFmt(fmt, args, 20.0, y, 12.0, TEXT);
}

export fn onUIFrame(_: f32, _: i32) void {
    if (!Settings.data.enabled) return;

    const vp = sdk.render.viewport();
    if (vp.x <= 0.0 or vp.y <= 0.0) return;

    const haystack = "Kittyscript Modules";
    var copy_buf: [32]u8 = undefined;
    const copied_len = sdk.util.copyText(copy_buf[0..], haystack);

    sdk.render.drawFilledRect(12.0, 12.0, 420.0, 300.0, sdk.rgba(0, 0, 0, 175));

    var y: f32 = 24.0;
    row(y, "rng: {d} samples, uniform next {d:.3}", .{ sample_count, sdk.random(-1.0, 1.0) });
    y += 18.0;
    row(y, "normalCdf(1.0) = {d:.4} (expected 0.8413)", .{sdk.util.random.normalCdf(1.0)});
    y += 18.0;
    row(y, "containsAsciiLower: {any}   copyText: {d} bytes \"{s}\"", .{
        sdk.util.containsAsciiLower(haystack, "modules"),
        copied_len,
        copy_buf[0..copied_len],
    });
    y += 18.0;
    row(y, "argbToHost(0x11223344) = 0x{X:0>8}", .{sdk.util.argbToHost(0x11223344)});

    var max_count: u32 = 1;
    for (histogram) |count| max_count = @max(max_count, count);
    const bar_w = 20.0;
    for (histogram, 0..) |count, i| {
        const height = 80.0 * @as(f32, @floatFromInt(count)) / @as(f32, @floatFromInt(max_count));
        const x = 24.0 + @as(f32, @floatFromInt(i)) * (bar_w + 2.0);
        sdk.render.drawFilledRect(x, 250.0 - height, bar_w, height, sdk.rgba(120, 200, 255, 230));
    }
    sdk.render.drawText("normalSample() histogram, bins over [-3, 3]", 24.0, 256.0, 11.0, sdk.rgba(170, 170, 170, 255));
}
