const runtime = @import("runtime");

pub const Bone = extern struct {
    /// Meters.
    position: runtime.Vec3,
    /// Index of the parent in the skeleton's `bones`; negative for a root.
    parent: i32,
};

/// Skeleton of one entity. `bones` stays valid until the next tick.
pub const Skeleton = struct {
    bones: []const Bone,
    /// Parent-to-child segments of the skeleton, at most 256. The result
    /// lives in a shared static buffer that the next call on any skeleton
    /// overwrites.
    pub fn lines(self: Skeleton) []const runtime.Line { _ = self; return undefined; }
    /// Index of the first root bone.
    pub fn findRoot(self: Skeleton) ?usize { _ = self; return undefined; }
};
