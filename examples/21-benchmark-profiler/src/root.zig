//! 21 — Benchmark / profiler readout
//!
//! Draws the per-frame profiler tree. Nodes arrive in pre-order — a node's
//! children are the following nodes with greater depth, up to the next node
//! at the same or lower depth — so indenting by `depth` renders the
//! hierarchy. `rootTotalNs` is the denominator for percentages and can be 0
//! before the first profile. Only debug builds publish a profile; release
//! builds report an empty tree. The slice from `nodes()` is valid until the
//! next published frame (`frameSeq` changes).

const sdk = @import("sdk");

const Settings = sdk.Settings("Profiler", struct {
    enabled: bool = true,
    max_rows: u32 = 12,
    show_calls: bool = true,
    min_ms: f32 = 0.0,
}, .{
    .enabled = .{ .display_name = "Enabled" },
    .max_rows = .{ .display_name = "Max Rows", .control = "slider", .min = 1, .max = 32 },
    .show_calls = .{ .display_name = "Show Call Counts" },
    .min_ms = .{ .display_name = "Hide Below (ms)", .control = "slider", .min = 0.0, .max = 10.0 },
});

const ROW_H = 15.0;

fn visibleCount(nodes: []const sdk.benchmark.Node, min_ms: f32, cap: usize) usize {
    var shown: usize = 0;
    for (nodes) |node| {
        if (shown == cap) break;
        if (node.label().len == 0) continue;
        if (@as(f32, @floatFromInt(node.total_ns)) / 1_000_000.0 < min_ms) continue;
        shown += 1;
    }
    return shown;
}

export fn onUIFrame(_: f32, _: i32) void {
    if (!Settings.data.enabled) return;

    const vp = sdk.render.viewport();
    if (vp.x <= 0.0 or vp.y <= 0.0) return;

    const nodes = sdk.benchmark.nodes();
    const root_ns = sdk.benchmark.rootTotalNs();
    const root_ms = @as(f32, @floatFromInt(root_ns)) / 1_000_000.0;

    const cap: usize = Settings.data.max_rows;
    const shown = visibleCount(nodes, Settings.data.min_ms, cap);
    const panel_h = 32.0 + @as(f32, @floatFromInt(@max(shown, 1))) * ROW_H;

    sdk.render.drawFilledRect(12.0, 12.0, 420.0, panel_h, sdk.rgba(0, 0, 0, 185));
    sdk.render.drawRect(12.0, 12.0, 420.0, panel_h, sdk.rgba(140, 140, 160, 200), 1.0);
    sdk.render.drawTextFmt("profile frame {d} - {d:.2} ms, {d} sections", .{
        sdk.benchmark.frameSeq(),
        root_ms,
        nodes.len,
    }, 22.0, 22.0, 12.0, sdk.rgba(230, 230, 230, 255));

    if (nodes.len == 0) {
        sdk.render.drawText("no profile published (debug builds only)", 22.0, 40.0, 11.0, sdk.rgba(180, 180, 180, 255));
        return;
    }

    var drawn: usize = 0;
    var y: f32 = 40.0;
    for (nodes) |*node| {
        if (drawn == shown) break;

        const ms = @as(f32, @floatFromInt(node.total_ns)) / 1_000_000.0;
        if (ms < Settings.data.min_ms or node.label().len == 0) continue;
        drawn += 1;

        const pct = if (root_ns > 0)
            sdk.clampf(@as(f32, @floatFromInt(node.total_ns)) / @as(f32, @floatFromInt(root_ns)), 0.0, 1.0)
        else
            0.0;
        const indent = 8.0 + @as(f32, @floatFromInt(node.depth)) * 12.0;

        sdk.render.drawText(node.label(), 22.0 + indent, y, 11.0, sdk.rgba(215, 215, 215, 255));
        if (Settings.data.show_calls) {
            sdk.render.drawTextFmt("({d})", .{node.call_count}, 250.0, y, 10.0, sdk.rgba(150, 150, 160, 255));
        }
        sdk.render.drawFilledRect(292.0, y + 3.0, 90.0, 5.0, sdk.rgba(50, 55, 65, 255));
        sdk.render.drawFilledRect(292.0, y + 3.0, 90.0 * pct, 5.0, sdk.rgba(120, 200, 255, 235));
        sdk.render.drawTextFmt("{d:.3} ms", .{ms}, 390.0, y, 10.0, sdk.rgba(220, 220, 220, 255));

        y += ROW_H;
    }
}
