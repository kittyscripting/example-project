const Transform = @import("transform.zig").Transform;

/// One recorded transform sample of an actor. `time_ms` is normally at or
/// before now; leading samples may be stamped ahead of the rendered pose.
pub const TransformSample = struct {
    /// Simulation-clock timestamp in milliseconds.
    time_ms: f32,
    /// Pose and motion at `time_ms`: meters, meters per second.
    transform: Transform,
};
