pub const S_OK: u32 = 0;
pub const CO_E_NOTINITIALIZED: u32 = 0x800401F0;
pub const E_ACCESSDENIED: u32 = 0x80070005;
pub const E_OUTOFMEMORY: u32 = 0x8007000E;
pub const REGDB_E_CLASSNOTREG: u32 = 0x80040154;

pub const foundation = @import("winrt/foundation.zig");
pub const ui = @import("winrt/ui.zig");

pub const IInspectable = @import("win32").system.win_rt.IInspectable;
