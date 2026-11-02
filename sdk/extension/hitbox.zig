const runtime = @import("runtime");

/// Spherical hitbox in world meters.
pub const SphereHitbox = extern struct {
    shape: runtime.Sphere,
    /// Skeleton bone the volume follows; negative when none.
    bone: i16,
    /// Critical hit area, e.g. a head.
    critical: bool,
};

/// Capsule hitbox in world meters.
pub const CapsuleHitbox = extern struct {
    shape: runtime.Capsule,
    /// Skeleton bone the volume follows; negative when none.
    bone: i16,
    /// Critical hit area, e.g. a head.
    critical: bool,
};

/// Oriented box hitbox in world meters.
pub const BoxHitbox = extern struct {
    shape: runtime.Box,
    /// Skeleton bone the volume follows; negative when none.
    bone: i16 = -1,
    /// Critical hit area, e.g. a head.
    critical: bool = false,
};

/// Hitboxes of one entity. The slices stay valid until the next tick.
pub const HitboxSet = struct {
    spheres: []SphereHitbox,
    capsules: []CapsuleHitbox,
    boxes: []BoxHitbox = &.{},
};
