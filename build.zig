const std = @import("std");

/// Application SDK packages, imported as `@import("<name>")`.
const app_names = [_][]const u8{
    "overwatch",
    "deadlock",
    "eft",
};

pub fn build(b: *std.Build) void {
    const target = b.resolveTargetQuery(.{ .cpu_arch = .wasm32, .os_tag = .freestanding });
    const optimize = b.standardOptimizeOption(.{ .preferred_optimize_mode = .ReleaseFast });

    // Core SDK: `sdk` imports `runtime` and `util`; `util` imports `runtime`.
    const runtime = addModule(b, "sdk/runtime/root.zig", target, optimize, &.{});
    const util = addModule(b, "sdk/util/root.zig", target, optimize, &.{
        .{ .name = "runtime", .module = runtime },
    });
    const sdk = addModule(b, "sdk/extension/root.zig", target, optimize, &.{
        .{ .name = "runtime", .module = runtime },
        .{ .name = "util", .module = util },
    });

    // Every module source can import `sdk` and each application package.
    // Application packages see the core SDK as `extension` and import
    // themselves so their nested files can reach the package root.
    var imports: [app_names.len + 1]std.Build.Module.Import = undefined;
    imports[0] = .{ .name = "sdk", .module = sdk };
    inline for (app_names, 1..) |name, index| {
        const app = addModule(b, "sdk/" ++ name ++ "/root.zig", target, optimize, &.{
            .{ .name = "runtime", .module = runtime },
            .{ .name = "util", .module = util },
            .{ .name = "extension", .module = sdk },
        });
        app.addImport(name, app);
        imports[index] = .{ .name = name, .module = app };
    }

    const check = b.step("check", "Analyze the module and every example without linking");
    b.default_step = check;

    const module = b.addObject(.{
        .name = "module",
        .root_module = addModule(b, "src/root.zig", target, optimize, &imports),
    });
    check.dependOn(&module.step);

    for (exampleNames(b)) |name| {
        const example = b.addObject(.{
            .name = name,
            .root_module = addModule(b, b.fmt("examples/{s}/src/root.zig", .{name}), target, optimize, &imports),
        });
        check.dependOn(&example.step);
    }
}

fn addModule(
    b: *std.Build,
    path: []const u8,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    imports: []const std.Build.Module.Import,
) *std.Build.Module {
    return b.createModule(.{
        .root_source_file = b.path(path),
        .target = target,
        .optimize = optimize,
        .pic = true,
        .imports = imports,
    });
}

/// Sorted names of the `examples/` directories that contain `src/root.zig`.
fn exampleNames(b: *std.Build) []const []const u8 {
    const io = b.graph.io;
    var dir = b.build_root.handle.openDir(io, "examples", .{ .iterate = true }) catch |err| switch (err) {
        error.FileNotFound => return &.{},
        else => std.debug.panic("unable to open examples/: {s}", .{@errorName(err)}),
    };
    defer dir.close(io);

    var names: std.ArrayList([]const u8) = .empty;
    var entries = dir.iterate();
    while (entries.next(io) catch |err| std.debug.panic("unable to read examples/: {s}", .{@errorName(err)})) |entry| {
        dir.access(io, b.fmt("{s}/src/root.zig", .{entry.name}), .{}) catch continue;
        names.append(b.allocator, b.dupe(entry.name)) catch @panic("OOM");
    }
    std.mem.sort([]const u8, names.items, {}, lessThan);
    return names.items;
}

fn lessThan(_: void, lhs: []const u8, rhs: []const u8) bool {
    return std.mem.lessThan(u8, lhs, rhs);
}
