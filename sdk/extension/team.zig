/// Relationship of an entity to the local actor.
pub const Team = enum {
    ally,
    enemy,
    /// Excluded from ordinary target selection.
    neutral,
    unknown,
};
