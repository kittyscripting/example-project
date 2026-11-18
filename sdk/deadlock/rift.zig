const extension = @import("extension");

/// Rift cue phase.
pub const RiftPhase = enum(u32) {
    inactive = 0,
    warning = 1,
    open = 2,
    hint = 3,
};

/// The current Unstable Rift cue. `active` is `phase != .inactive`; a new
/// `cycle_id` marks a new rift.
pub const RiftCue = struct {
    active: bool,
    phase: RiftPhase,
    /// World position in meters.
    position: extension.Vec3,
    cycle_id: u64,
};

/// Current Unstable Rift cue.
pub fn riftCue() RiftCue { return undefined; }
