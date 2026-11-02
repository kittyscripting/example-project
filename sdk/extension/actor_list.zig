/// One entry of a module's actor roster.
pub const ActorListEntry = struct {
    /// Actor type id used for per-actor settings scoping; never shown to
    /// users. Must be non-zero.
    id: u64,
    /// Display name, 1 to 64 bytes.
    name: []const u8,
};

/// Declare this module's actor roster for per-actor settings. Ids must be
/// non-zero and unique; names 1 to 64 bytes. Reference the returned type
/// (e.g. `.count`) to emit the roster.
pub fn ActorList(comptime entries: []const ActorListEntry) type {
    return struct {
        pub const count = entries.len;
    };
}
