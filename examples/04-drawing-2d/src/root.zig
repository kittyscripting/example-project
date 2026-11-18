//! 04 — 2D drawing primitives
//!
//! A gallery of the core 2D primitives: lines, outlined and filled
//! rectangles, outlined and filled circles, and text: single-line
//! (left-aligned and centered) plus one bounded box that wraps a paragraph
//! and truncates it with an ellipsis. Coordinates are logical pixels from
//! the top-left of the viewport; alpha is honored for filled shapes.

const sdk = @import("sdk");

const WHITE = sdk.rgba(240, 240, 240, 255);
const DIM = sdk.rgba(150, 150, 150, 255);

const body =
    "Text is a single line unless you wrap it. The text layout helper breaks " ++
    "this paragraph at the inner width, counts whole rows against the inner " ++
    "height, and marks the last visible row with an ellipsis when the text " ++
    "does not fit.";

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

    // Fit a padded backdrop to the label at its draw size.
    const label = "drawText - left aligned";
    const size = 15.0;
    const pad = 4.0;
    const bounds = sdk.render.measureText(label, size);
    sdk.render.drawFilledRect(40.0 - pad, 400.0 - pad, bounds.width + 2 * pad, bounds.height + 2 * pad, sdk.rgba(40, 60, 90, 220));
    sdk.render.drawText(label, 40.0, 400.0, size, WHITE);
    sdk.render.drawTextCentered("drawTextCentered", vp.x * 0.5, 430.0, 15.0, sdk.rgba(180, 210, 255, 255));

    // Bounded text box. `heightForWidth` is the fixed-width bound: how tall
    // this paragraph needs to be at the inner width. It is capped here so the
    // box stays bounded and the last visible line ends in "...". `wrap`
    // breaks the text to the inner width and stops at the inner height; its
    // mirror, `widthForHeight`, gives the narrowest width for a fixed height.
    // Lines borrow `body`; only the ellipsis line borrows `scratch`, so draw
    // each line before calling `next` again.
    const box_x = 460.0;
    const box_y = 40.0;
    const box_w = 300.0;
    const box_pad = 8.0;
    const box_size = 12.0;
    const inner_w = box_w - 2.0 * box_pad;
    const max_inner_h = 104.0;
    const needed_h = sdk.render.text_layout.heightForWidth(body, box_size, inner_w) orelse max_inner_h;
    const inner_h = @min(needed_h, max_inner_h);
    const box_h = inner_h + 2.0 * box_pad;
    const line_h = sdk.render.measureText("M", box_size).height;
    sdk.render.drawFilledRect(box_x, box_y, box_w, box_h, sdk.rgba(20, 25, 35, 200));
    sdk.render.drawRect(box_x, box_y, box_w, box_h, DIM, 1.0);
    var layout = sdk.render.text_layout.wrap(body, box_size, inner_w, inner_h);
    var scratch: [256]u8 = undefined;
    var line_y: f32 = box_y + box_pad;
    while (layout.next(&scratch)) |line| : (line_y += line_h) {
        sdk.render.drawText(line, box_x + box_pad, line_y, box_size, WHITE);
    }

    sdk.render.drawText("drawLine", 40.0, 26.0, 11.0, DIM);
    sdk.render.drawText("drawRect / drawFilledRect", 40.0, 146.0, 11.0, DIM);
    sdk.render.drawText("drawCircle (outline / filled)", 40.0, 278.0, 11.0, DIM);
}
