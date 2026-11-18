//! 01 — Hello, lifecycle
//!
//! Logs on load and unload, counts ticks and rendered frames, and draws both
//! plus the newest log line in the top-left corner. `sdk.log` takes a raw
//! string; `info`/`warn`/`err` take a format string and an argument tuple.

const sdk = @import("sdk");

var ticks: u32 = 0;
var frames: u32 = 0;

export fn onLoad() void {
    sdk.log("hello: onLoad");
    sdk.info("hello: module loaded", .{});
}

export fn onUnload() void {
    sdk.info("hello: unloaded after {d} ticks / {d} frames", .{ ticks, frames });
}

export fn onTick(dt: f32, _: i32) void {
    ticks += 1;
    if (ticks == 1) {
        sdk.warn("hello: first tick after {d:.3}s (dt {d:.4}s)", .{ sdk.tickTime(), dt });
    }
}

export fn onFrame(dt: f32, _: i32) void {
    frames += 1;

    const vp = sdk.render.viewport();
    if (vp.x <= 0.0 or vp.y <= 0.0) return;

    sdk.render.drawTextFmt(
        "ticks {d}   frames {d}   logic {any}   dt {d:.1}ms",
        .{ ticks, frames, sdk.isLogicFrame(), dt * 1000.0 },
        12.0,
        12.0,
        14.0,
        sdk.rgba(255, 255, 255, 255),
    );

    const total = sdk.logCount();
    if (total > 0) {
        sdk.render.drawText(sdk.logHistory(total - 1, total), 12.0, 32.0, 12.0, sdk.rgba(150, 210, 150, 255));
    }
}
