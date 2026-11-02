//! 04 — 2D drawing primitives
//!
//! A gallery of the core 2D primitives: lines, outlined and filled
//! rectangles, outlined and filled circles, and single-line text
//! (left-aligned and centered). Coordinates are logical pixels from the
//! top-left of the viewport; alpha is honored for filled shapes.

const sdk = @import("sdk");

const WHITE = sdk.rgba(240, 240, 240, 255);
const DIM = sdk.rgba(150, 150, 150, 255);

export fn onUIFrame(_: f32, _: i32) void {
    const vp = sdk.render.viewport();
    if (vp.x <= 0.0 or vp.y <= 0.0) return;

    // Faint 100 px grid.
    var x: f32 = 0.0;
    while (x < vp.x) : (x += 100.0) {
        sdk.render.drawLine(x, 0.0, x, vp.y, sdk.rgba(255, 255, 255, 12));
    }
    var y: f32 = 0.0;
    while (y < vp.y) : (y += 100.0) {
        sdk.render.drawLine(0.0, y, vp.x, y, sdk.rgba(255, 255, 255, 12));
    }

    // Lines have no width parameter: a second parallel line thickens the stroke.
    sdk.render.drawLine(40.0, 40.0, 240.0, 120.0, sdk.rgba(255, 90, 90, 255));
    sdk.render.drawLine(40.0, 42.0, 240.0, 122.0, sdk.rgba(255, 90, 90, 255));

    // Outlined rectangle (stroke width) and a filled rectangle with a border.
    sdk.render.drawRect(40.0, 160.0, 180.0, 90.0, sdk.rgba(120, 220, 120, 255), 2.0);
    sdk.render.drawFilledRect(260.0, 160.0, 180.0, 90.0, sdk.rgba(40, 90, 170, 190));
    sdk.render.drawRect(260.0, 160.0, 180.0, 90.0, WHITE, 1.0);

    // Circles: the last argument selects filled or outlined.
    sdk.render.drawCircle(90.0, 320.0, 36.0, sdk.rgba(255, 205, 60, 255), false);
    sdk.render.drawCircle(190.0, 320.0, 36.0, sdk.rgba(255, 205, 60, 170), true);

    // Text is a single line, clipped at 256 bytes; centered text centers on x.
    sdk.render.drawText("drawText - left aligned", 40.0, 400.0, 15.0, WHITE);
    sdk.render.drawTextCentered("drawTextCentered", vp.x * 0.5, 430.0, 15.0, sdk.rgba(180, 210, 255, 255));

    sdk.render.drawText("drawLine", 40.0, 26.0, 11.0, DIM);
    sdk.render.drawText("drawRect / drawFilledRect", 40.0, 146.0, 11.0, DIM);
    sdk.render.drawText("drawCircle (outline / filled)", 40.0, 278.0, 11.0, DIM);
}
