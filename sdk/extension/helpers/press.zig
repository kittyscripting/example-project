/// Time a module's own press started, kept down for `min_press_ms`. The button
/// and its release stay with the module.
pub const Press = struct {
    /// Record a press at `now_ms`.
    pub fn start(self: *Press, now_ms: f32) void { _ = self; _ = now_ms; }
    /// Forget the press; nothing is released.
    pub fn clear(self: *Press) void { _ = self; }
    /// A press is recorded and not yet settled.
    pub fn active(self: *const Press) bool { _ = self; return undefined; }
    /// Whether the press started less than `min_press_ms` before `now_ms`.
    pub fn holding(self: *const Press, now_ms: f32) bool { _ = self; _ = now_ms; return undefined; }
    /// Whether the press must stay down this update; a press that reached
    /// `min_press_ms` is forgotten.
    pub fn settle(self: *Press, now_ms: f32) bool { _ = self; _ = now_ms; return undefined; }
};
