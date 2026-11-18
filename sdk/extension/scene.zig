const Actor = @import("actor.zig").Actor;
const Prop = @import("prop.zig").Prop;
const LocalActor = @import("local_actor.zig").LocalActor;

/// Actors of the current tick; empty when none exist.
pub fn actors() []Actor { return undefined; }

/// Props of the current tick; empty when none exist.
pub fn props() []Prop { return undefined; }

/// The local actor of the current tick, or null when none is available.
pub fn localActor() ?*LocalActor { return undefined; }

/// True during a running match; false in menus and loading.
pub fn inSimulation() bool { return undefined; }
