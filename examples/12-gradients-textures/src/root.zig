//! 12 — Gradients and textures
//!
//! Gradient and radial fills, plus a checkerboard texture built in memory as
//! tightly packed BGRA bytes (`w * h * 4`), uploaded once, drawn scaled and at
//! native size, and freed on unload. `uploadBitmap` returns 0 on failure and
//! the texture is retried on the next frame.

const sdk = @import("sdk");

const Settings = sdk.Settings("Gradients & Textures", struct {
    enabled: bool = true,
    tile_size: u32 = 128,
    tint: u32 = 0xFF66CCFF,
}, .{
    .enabled = .{ .display_name = "Enabled" },
    .tile_size = .{ .display_name = "Texture Size (px)", .control = "slider", .min = 32, .max = 256 },
    .tint = .{ .display_name = "Tint", .control = "color" },
});

/// Settings colors are `0xAARRGGBB`; draw calls take `0xAABBGGRR`.
fn color(argb: u32) i32 {
    return @bitCast(sdk.util.argbToHost(argb));
}

const TEX: u32 = 32;

var texid: u32 = 0;

fn uploadCheckerboard() void {
    var pixels: [TEX * TEX * 4]u8 = undefined;
    for (0..TEX) |y| {
        for (0..TEX) |x| {
            const light = ((x / 4) + (y / 4)) % 2 == 0;
            const i = (y * TEX + x) * 4;
            pixels[i + 0] = if (light) 235 else 45; // blue
            pixels[i + 1] = if (light) 235 else 45; // green
            pixels[i + 2] = if (light) 245 else 65; // red
            pixels[i + 3] = 255; // alpha
        }
    }
    texid = sdk.render.uploadBitmap(&pixels, TEX, TEX);
}

export fn onUnload() void {
    sdk.render.freeTexture(texid);
}

export fn onUIFrame(_: f32, _: i32) void {
    if (!Settings.data.enabled) return;
    if (texid == 0) uploadCheckerboard();

    sdk.render.drawGradientLine(40.0, 40.0, 300.0, 40.0, sdk.rgba(255, 60, 60, 255), sdk.rgba(60, 60, 255, 255));
    sdk.render.drawGradientRect(
        40.0,
        70.0,
        260.0,
        120.0,
        sdk.rgba(255, 80, 80, 255), // top-left
        sdk.rgba(80, 255, 80, 255), // top-right
        sdk.rgba(80, 80, 255, 255), // bottom-right
        sdk.rgba(255, 255, 80, 255), // bottom-left
    );
    sdk.render.drawRadialCircle(120.0, 280.0, 70.0, sdk.rgba(255, 255, 255, 220), sdk.rgba(255, 120, 0, 0));
    sdk.render.drawGradientTriangle(
        220.0,
        230.0,
        300.0,
        230.0,
        260.0,
        330.0,
        sdk.rgba(255, 60, 60, 255),
        sdk.rgba(60, 255, 120, 255),
        sdk.rgba(60, 120, 255, 255),
    );

    // Tinted panel behind the checkerboard, scaled and at native size.
    const tile: f32 = @floatFromInt(Settings.data.tile_size);
    const x = 40.0;
    const y = 370.0;
    sdk.render.drawFilledRect(x - 2.0, y - 2.0, tile + 4.0, tile + 4.0, color(Settings.data.tint));
    if (texid != 0) {
        sdk.render.drawTextureScaled(texid, x, y, tile, tile);
        sdk.render.drawTexture(texid, x + tile + 12.0, y);
    }

    sdk.render.drawText("gradient line / rect / radial / triangle", 40.0, 24.0, 12.0, sdk.rgba(200, 200, 200, 255));
    sdk.render.drawTextFmt("texture id {d} ({d}x{d})", .{ texid, TEX, TEX }, x, y + tile + 8.0, 12.0, sdk.rgba(220, 220, 220, 255));
}
