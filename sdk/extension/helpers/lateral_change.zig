/// Lateral velocity change (m/s) that counts as a change when exceeded.
pub const lateralChangeMps: f32 = 2.0;

/// Age (ms) of the baseline sample a new sample is compared against.
pub const changeWindowMs: f32 = 100.0;

/// Lateral change detector over `V` (`x` and `z: f32`).
pub fn LateralChange(comptime V: type) type {
    return struct {
        const Self = @This();

        pub fn reset(self: *Self) void { _ = self; }

        /// Time (ms) of the latest observed sample.
        pub fn lastSampleMs(self: *const Self) ?f32 { _ = self; return undefined; }

        /// Record one sample; true when its lateral velocity differs from the
        /// baseline sample by more than `lateralChangeMps` and no change is
        /// already in progress.
        pub fn observe(self: *Self, velocity: V, time_ms: f32, lateralAxis: V) bool { _ = self; _ = velocity; _ = time_ms; _ = lateralAxis; return undefined; }
    };
}
