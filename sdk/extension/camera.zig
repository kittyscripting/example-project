const runtime = @import("runtime");

/// Eye position in world meters while a camera is active, else null. The eye
/// sits above the actor origin; use it as the ray origin for view-direction
/// math and fall back to the actor origin when null.
pub fn position() ?runtime.Vec3 { return undefined; }

/// Whether a camera and projection are available for the current frame.
/// Frame callbacks run regardless; gate `w2s` and 3D draws on this.
pub fn active() bool { return undefined; }

/// Project a world position in meters to viewport pixels (y
/// down). Null when no projection is available or the point is behind the
/// camera. Off-screen points may project outside the viewport; clip first.
pub fn w2s(pos: runtime.Vec3) ?runtime.Vec2 { _ = pos; return undefined; }
