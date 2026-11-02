/// Number of registered settings categories; valid `View.fetch` indices are
/// `[0, count())`.
pub fn count() usize { return undefined; }

/// Record the current value of every setting field as the baseline for the
/// next `save()`. Returns immediately.
pub fn snapshot() void {}

/// Persist every setting field whose value changed since the last
/// `snapshot()`. A changed value equal to the schema default clears the
/// stored value. Returns immediately; persistence completes asynchronously.
pub fn save() void {}

/// One actor available for per-actor configuration: `id` selects the scope
/// via `setScope`, `name` is the display label.
pub const ActorInfo = struct {
    id: u64,
    name: []const u8,
};

/// Number of actors available for per-actor configuration, sorted by name.
pub fn actorCount() usize { return undefined; }

/// Fetch actor `idx` in `[0, actorCount())`. The returned name slice points
/// into `buf`; returns null when `idx` is invalid or `buf` is too small
/// (10 bytes plus the name length). A 74-byte buffer fits any name.
pub fn actor(idx: usize, buf: []u8) ?ActorInfo { _ = idx; _ = buf; return undefined; }

/// Point subsequent `snapshot()`/`save()` at the per-actor values of
/// `actor_id` (`null` = Global scope). Requires an active edit session;
/// returns false when the scope is rejected (no session, or the id is not in
/// the actor list).
pub fn setScope(actor_id: ?u64) bool { _ = actor_id; return undefined; }

/// Reset one field's live value to what it inherits in the current scope
/// (Global scope: schema default; actor scope: global effective value).
/// Indices match the order used by `View.fetch`; returns false when either
/// index is invalid.
pub fn resetField(entry_idx: usize, field_idx: usize) bool { _ = entry_idx; _ = field_idx; return undefined; }

/// Whether the field's live value is an actor override in the current edit
/// scope: true only while an actor-scoped session is open and the live value
/// differs from the global effective value, which is exactly when `save()`
/// stores an override. Global scope, no session, the `@runtime` entry and
/// inherited fields return false. Indices match the order used by
/// `View.fetch`; invalid indices return false.
pub fn isOverridden(entry_idx: usize, field_idx: usize) bool { _ = entry_idx; _ = field_idx; return undefined; }

/// Whether the field is declared global-only: it has no per-actor value, so
/// actor scope neither shows it nor writes an override for it. Indices match
/// the order used by `View.fetch`; invalid indices return false.
pub fn isGlobalOnly(entry_idx: usize, field_idx: usize) bool { _ = entry_idx; _ = field_idx; return undefined; }

/// Sort priority a category declares for settings UIs (`.priority` on the
/// `Settings` declaration); 0 when it declares none. Categories list by
/// priority descending, then display name A-Z ignoring case. Indices match the
/// order used by `View.fetch`; invalid indices return null.
pub fn categoryPriority(entry_idx: usize) ?u8 { _ = entry_idx; return undefined; }

/// Schema of one setting field within a category entry. Value slots are raw
/// little-endian bytes: for `default`, `min` and `max`, only the first
/// `size` bytes are meaningful; decode them with `slotValue`. `type_tag`
/// identifies the field type:
/// 0 = `bool`, 1 = `i64`, 2 = `f64`, 3 = `i32`, 4 = `u32`, 5 = `f32`.
pub const Field = struct {
    /// Field identifier, matching the field name in the declaring struct.
    name: []const u8,
    /// Numeric type tag; see the Field doc for the mapping.
    type_tag: u8,
    /// Byte offset of the field value within the category field storage.
    offset: u32,
    /// Byte size of the field value.
    size: u32,
    /// Schema default value as a raw little-endian slot.
    default: [16]u8,
    /// Inclusive minimum as a raw little-endian slot, when constrained.
    min: ?[16]u8,
    /// Inclusive maximum as a raw little-endian slot, when constrained.
    max: ?[16]u8,
    /// User-facing label.
    display: []const u8,
    /// User-facing description, possibly empty.
    description: []const u8,
    /// UI widget name: `slider`, `multi`, `keybind`, `colorpicker`, or empty
    /// for a bool toggle.
    control: []const u8,
    /// Selectable labels for the `multi` control; empty for other controls.
    options: []const []const u8,
};

/// One settings category: the module that declared it, its display category,
/// and the schema of its fields.
pub const Entry = struct {
    /// Base of the category field storage; a field's value lives at
    /// `base + field offset` (see `valuePtr`).
    base: u32,
    /// Name of the module that declared the category.
    module_name: []const u8,
    /// Display category name.
    category: []const u8,
    /// Field schemas in declaration order.
    fields: []const Field,
};

/// Storage that `fetch` decodes one settings category into. Keep a `View` in
/// static memory; it is too large for the stack.
pub const View = struct {
    /// Encoded category bytes; returned `Entry` strings point here.
    bytes: [65536]u8 = undefined,
    /// Field schemas; a category with more than 256 fields is skipped.
    fields_buf: [256]Field = undefined,
    /// Option labels shared by all fields; a category with more than 256
    /// options in total is skipped.
    options_buf: [256][]const u8 = undefined,
    /// Decode category `idx` in `[0, count())` into this view. The returned
    /// entry points into the view and stays valid until the next `fetch`.
    /// Returns null when `idx` is invalid or the category exceeds the view's
    /// capacity.
    pub fn fetch(self: *View, idx: usize) ?Entry { _ = self; _ = idx; return undefined; }
};

/// Live value of a setting field: `base` from `Entry.base`, `offset` from `Field.offset`.
pub fn valuePtr(comptime T: type, base: u32, offset: u32) *T { _ = base; _ = offset; return undefined; }

/// Decode a schema value slot (`Field.default`, `.min`, `.max`) as `T`.
pub fn slotValue(comptime T: type, slot: [16]u8) T { _ = slot; return undefined; }

/// Live value of `field` within `entry` as f64; bool reads as 0 or 1.
/// NaN when `type_tag` is unknown or `size` is below the tag's width.
pub fn getNumber(entry: Entry, field: Field) f64 { _ = entry; _ = field; return undefined; }

/// `Field.default` as f64; bool reads as 0 or 1.
/// NaN when `type_tag` is unknown or `size` is below the tag's width.
pub fn getDefault(field: Field) f64 { _ = field; return undefined; }

/// `Field.min` as f64, or null when unconstrained.
/// NaN when `type_tag` is unknown or `size` is below the tag's width.
pub fn getMin(field: Field) ?f64 { _ = field; return undefined; }

/// `Field.max` as f64, or null when unconstrained.
/// NaN when `type_tag` is unknown or `size` is below the tag's width.
pub fn getMax(field: Field) ?f64 { _ = field; return undefined; }
