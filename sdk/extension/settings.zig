/// Declare a user-editable settings category that persists across sessions.
///
/// `category` is the display name string, or a struct literal
/// `.{ .name = "Display Name", .priority = 100 }`:
/// - `.name`: display name; must be unique among categories.
/// - `.priority`: `u8` sort priority in settings UIs, default 0. Categories
/// list by priority descending, then display name A-Z ignoring case.
///
/// The persistence id is the display name lowercased with every run of other
/// characters collapsed to one `_` and leading/trailing `_` trimmed
/// (`"X-Ray (Visuals)"` -> `"x_ray_visuals"`); a name without letters or
/// digits is rejected. Renaming a category changes its id.
///
/// Each field of `Spec` is a setting of type `bool`, `i32`, `u32`, `i64`,
/// `f32`, or `f64` and needs a default value; the settings UI lists fields in
/// declaration order.
/// `constraints` maps field names to structs with any of:
/// - `.min`, `.max`: bounds of a numeric field.
/// - `.display_name`, `.description`: UI text.
/// - `.control`: UI widget, e.g. `"multi"` or `"keybind"`.
/// - `.options`: labels of a `"multi"` control.
/// - `.global_only`: `true` for a setting with no per-actor value; a
/// global-only setting is hidden in actor scope.
///
/// The returned type's `data` holds the live values; during `onLoad` they
/// are still the defaults.
pub fn Settings(
    comptime category: anytype,
    comptime Spec: type,
    comptime constraints: anytype,
) type {
    const info = switch (@typeInfo(Spec)) {
        .@"struct" => |value| value,
        else => @compileError("settings spec must be a struct"),
    };
    const category_kind = @typeInfo(@TypeOf(category));
    const display_name = switch (category_kind) {
        .@"struct" => category.name,
        else => category,
    };
    const priority: u8 = switch (category_kind) {
        .@"struct" => if (@hasField(@TypeOf(category), "priority")) category.priority else 0,
        else => 0,
    };
    if (display_name.len == 0) {
        @compileError("settings category must not be empty");
    }
    inline for (display_name) |ch| {
        if (ch < 0x20 or ch > 0x7e) {
            @compileError("settings category must be printable ASCII");
        }
    }
    if (display_name.len >= 0xFFFF) {
        @compileError("settings category name must fit in u16 length field");
    }
    inline for (info.fields) |field| {
        if (field.defaultValue() == null) {
            @compileError("settings field '" ++ field.name ++ "' requires a default value");
        }
        if (field.type != bool and field.type != i64 and field.type != f64 and
            field.type != i32 and field.type != u32 and field.type != f32)
        {
            @compileError("unsupported settings field type: " ++ @typeName(field.type) ++ " on '" ++ field.name ++ "'");
        }
    }
    _ = constraints;

    return struct {
        pub const Data = Spec;
        pub var data: Data = .{};
        pub const category_name = normalizeCategoryId(display_name);
        pub const category_priority = priority;

        comptime {
            if (category_name.len == 0) {
                @compileError("settings category name must contain a letter or digit");
            }
        }

        /// Persistence id: letters lowercased, digits kept, each run of other
        /// characters one `_`, no leading or trailing `_`.
        fn normalizeCategoryId(comptime name: []const u8) []const u8 {
            comptime {
                var buffer: [name.len]u8 = undefined;
                var len: usize = 0;
                var separated = false;
                for (name) |ch| {
                    const kept = switch (ch) {
                        'A'...'Z' => ch + ('a' - 'A'),
                        'a'...'z', '0'...'9' => ch,
                        else => 0,
                    };
                    if (kept == 0) {
                        separated = true;
                        continue;
                    }
                    if (separated and len > 0) {
                        buffer[len] = '_';
                        len += 1;
                    }
                    separated = false;
                    buffer[len] = kept;
                    len += 1;
                }
                const final = buffer[0..len].*;
                return &final;
            }
        }
    };
}
