/// One stat value. `key` is a tag of the title SDK's stat enum, which
/// documents the meaning of `value` per key.
pub const StatEntry = extern struct {
    key: u32,
    value: f32,
};

/// Title-defined stat values of one entity, in no particular order.
/// `entries` stays valid until the next tick.
pub const Stats = struct {
    entries: []StatEntry,
    /// Value of `key`, any `enum(u32)` of the title SDK; null when absent.
    pub fn get(self: Stats, key: anytype) ?f32 { _ = self; _ = key; return undefined; }
};
