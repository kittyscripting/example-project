pub const name_capacity: usize = 27;

/// One timed section of the frame tree.
pub const Node = extern struct {
    /// UTF-8; see `label`.
    name: [name_capacity]u8 = [_]u8{0} ** name_capacity,
    name_len: u8 = 0,
    /// 0 for top-level sections.
    depth: u8 = 0,
    /// Nanoseconds summed over every call this frame.
    total_ns: i64 = 0,
    call_count: u32 = 0,
    pub fn label(self: *const Node) []const u8 { _ = self; return undefined; }
};

/// Advances once per profiled frame; a change means a fresh profile.
pub fn frameSeq() u32 { return undefined; }

pub fn nodeCount() usize { return undefined; }

/// Nanoseconds spanned by the whole frame, the denominator for per-node
/// percentages.
pub fn rootTotalNs() i64 { return undefined; }

/// Current frame's sections in pre-order, valid until the next frame. Empty
/// until a profile exists.
pub fn nodes() []const Node { return undefined; }
