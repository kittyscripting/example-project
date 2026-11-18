/// Accumulated simulation time in seconds. Advances once per simulation
/// update by the elapsed time of that update; never decreases within a run.
pub fn tickTime() f32 { return undefined; }

/// Accumulated render-frame time in seconds. Advances once per rendered
/// frame; it is wall-clock-paced and does not track app pause.
pub fn frameTime() f32 { return undefined; }

/// Whether the current update is an app-logic frame. Set before each
/// simulation update; true when no value has been set.
pub fn isLogicFrame() bool { return undefined; }

/// Whether the next update is estimated to be an app-logic frame, so input
/// set in this update lands in a command whose angle is the local actor's
/// `viewDirection()`. Set before each simulation update; true when no estimate
/// has been set.
pub fn isNextFrameLogic() bool { return undefined; }
