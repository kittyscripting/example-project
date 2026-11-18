const Transform = @import("transform.zig").Transform;
const Team = @import("team.zig").Team;

/// Non-character scene object such as a deployable, pickup, or effect
/// marker. Listed by `props()`, never by `actors()`.
pub const Prop = struct {
    id: i32,
    /// Type id in the current title's vocabulary.
    type_id: u64,
    team: Team = .unknown,
    /// Id of the owning actor; 0 when unowned.
    owner: i32 = 0,
    transform: Transform = .{},
};
