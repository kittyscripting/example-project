/// Wall-clock and monotonic time, in whole seconds.
pub const SystemTime = extern struct {
    /// Seconds since the Unix epoch (UTC); 0 when unavailable.
    unix_secs: u64,
    /// Monotonic seconds; only differences are meaningful.
    monotonic_secs: u64,
};

/// Current time.
pub fn systemTime() SystemTime { return undefined; }
