/// How one sample's velocity compares with the recent rhythm.
pub const Change = enum {
    none,
    expected,
    unexpected,
    teleport,
};

/// Per-channel classifications of one sample.
pub const Changes = struct {
    horizontal: Change = .none,
    vertical: Change = .none,
};

/// Default rhythm window (ms).
pub const default_pattern_window_ms: f32 = 1200.0;

/// Default teleport position error (m).
pub const default_teleport_meters: f32 = 0.5;

/// Default vertical velocity change rate (m/s²).
pub const default_vertical_accel: f32 = 100.0;

/// Motion tracking parameters.
pub const Config = struct {
    /// Back-and-forth rhythm lifetime after its last reversal (ms).
    pattern_window_ms: f32 = default_pattern_window_ms,
    /// Per-channel position error (m) over one sample beyond the motion the
    /// velocities explain; above it the channel reports `.teleport`.
    teleport_meters: f32 = default_teleport_meters,
    /// Vertical velocity change rate (m/s²) above which a jump, landing, or
    /// knock-up counts as a vertical change.
    vertical_accel: f32 = default_vertical_accel,
    /// Every threshold divided by `accuracy_mul`; 0 makes them infinite.
    pub fn scaled(accuracy_mul: f32) Config { _ = accuracy_mul; return undefined; }
};

/// Motion history of one target. `V` needs `x`, `y`, `z: f32` and `add`,
/// `sub`, `scale`, `dot`, `lengthSq`.
pub fn MotionTracker(comptime V: type) type {
    return struct {
        const Self = @This();

        /// Clear samples, leg direction, reversals, and the latest sample.
        pub fn reset(self: *Self) void { _ = self; }

        /// Timestamp (ms) of the newest recorded sample; null before the first.
        pub fn lastSampleMs(self: *const Self) ?f32 { _ = self; return undefined; }

        /// Record one sample: velocity (m/s) and position (m) at `nowMs`.
        pub fn observe(self: *Self, velocity: V, position: V, nowMs: f32, config: Config) Changes { _ = self; _ = velocity; _ = position; _ = nowMs; _ = config; return undefined; }

        /// Whether a horizontal back-and-forth rhythm is established at `nowMs`.
        pub fn oscillating(self: *const Self, nowMs: f32, config: Config) bool { _ = self; _ = nowMs; _ = config; return undefined; }

        /// Fraction in [0, 1] of a horizontal lead spanning `lead_seconds` the
        /// target is expected to complete before its next reversal; 1 when no
        /// rhythm is established or `leadSeconds <= 0`.
        pub fn leadScale(self: *const Self, nowMs: f32, lead_seconds: f32, config: Config) f32 { _ = self; _ = nowMs; _ = lead_seconds; _ = config; return undefined; }
    };
}

/// `v` with its horizontal (x, z) components multiplied by `factor`.
pub fn scaleHorizontal(comptime V: type, v: V, factor: f32) V { _ = v; _ = factor; return undefined; }
