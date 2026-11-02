/// Emit `msg` unformatted.
pub fn log(msg: []const u8) void { _ = msg; }

/// Emit an INFO line. Lines are formatted into a 1 KiB buffer; a line that
/// overflows or fails becomes `[INFO] <fmt error>`.
pub fn info(comptime fmt: []const u8, args: anytype) void { _ = fmt; _ = args; }

/// Emit a WARN line; see `info`.
pub fn warn(comptime fmt: []const u8, args: anytype) void { _ = fmt; _ = args; }

/// Emit an ERROR line; see `info`.
pub fn err(comptime fmt: []const u8, args: anytype) void { _ = fmt; _ = args; }

/// Log lines emitted so far; only the latest 1024 are retained.
pub fn logCount() i32 { return undefined; }

/// Newline-joined retained lines in `[from, to)` (`logCount` sequence),
/// clamped to what remains. Overwritten by the next call; empty when the
/// range is empty or the text exceeds 4 KiB.
pub fn logHistory(from: i32, to: i32) []const u8 { _ = from; _ = to; return undefined; }
