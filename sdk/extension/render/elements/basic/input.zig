/// Whether `vk` is currently down.
pub fn down(vk: u8) bool { _ = vk; return undefined; }

/// True on the frame the key goes down.
pub fn pressed(vk: u8) bool { _ = vk; return undefined; }

/// True on the frame the key goes up.
pub fn released(vk: u8) bool { _ = vk; return undefined; }

/// True on the press, then while held: after `initial_delay` frames and
/// every `repeat_period` frames from then on.
pub fn pressedRepeat(vk: u8, initial_delay: u16, repeat_period: u16) bool { _ = vk; _ = initial_delay; _ = repeat_period; return undefined; }
