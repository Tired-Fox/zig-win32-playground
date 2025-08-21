const win32 = @import("win32");


pub const S_OK: u32 = 0;
pub const CO_E_NOTINITIALIZED: u32 = 0x800401F0;
pub const CO_E_NOT_SUPPORTED: u32 = 0x80004021;
pub const E_ACCESSDENIED: u32 = 0x80070005;
pub const E_NOINTERFACE: u32 = 0x80004002;
pub const E_OUTOFMEMORY: u32 = 0x8007000E;
pub const REGDB_E_CLASSNOTREG: u32 = 0x80040154;

pub const foundation = @import("winrt/foundation.zig");
pub const ui = @import("winrt/ui.zig");
pub const data = @import("winrt/data.zig");

pub const IInspectable = @import("win32").system.win_rt.IInspectable;
pub const HSTRING = win32.system.win_rt.HSTRING;

pub fn WindowsCreateString(string: [:0]const u16) !?HSTRING {
    var result: ?HSTRING = undefined;
    if (win32.system.win_rt.WindowsCreateString(string.ptr, @intCast(string.len), &result) != S_OK) {
        return error.OutOfMemory;
    }
    return result;
}

pub fn WindowsDeleteString(string: ?HSTRING) void {
    _ = win32.system.win_rt.WindowsDeleteString(string);
}

pub fn GetRestrictedErrorInfo() ?*win32.system.win_rt.IRestrictedErrorInfo {
    var result: ?*win32.system.win_rt.IRestrictedErrorInfo = undefined;
    if (win32.system.win_rt.GetRestrictedErrorInfo(&result) == S_OK) {
        return result;
    }
    return null;
}
