const std = @import("std");

const window = @import("window");
const win_rt = window.win_rt;

const win32 = @import("win32");
const foundation = win32.foundation;
const windows_and_messaging = win32.ui.windows_and_messaging;

const CreateWindow = win32.ui.windows_and_messaging.CreateWindowExA;
const GetModuleHandle = win32.system.library_loader.GetModuleHandleA;
const RegisterClass = win32.ui.windows_and_messaging.RegisterClassA;

const ShowWindow = win32.ui.windows_and_messaging.ShowWindow;

const WNDCLASS = win32.ui.windows_and_messaging.WNDCLASSA;
const WINDOW_STYLE = win32.ui.windows_and_messaging.WINDOW_STYLE;
const WNDCLASS_STYLES = win32.ui.windows_and_messaging.WNDCLASS_STYLES;

pub fn main() !void {
    const class: [:0]align(1) const u8 = "win-win-simple-1";
    const title: [:0]const u8 = "title goes here";

    const instance = GetModuleHandle(null);
    const wnd_class = WNDCLASS{ .lpszClassName = class.ptr, .style = WNDCLASS_STYLES{ .HREDRAW = 1, .VREDRAW = 1 }, .cbClsExtra = 0, .cbWndExtra = 0, .hIcon = null, .hCursor = null, .hbrBackground = win32.graphics.gdi.GetStockObject(win32.graphics.gdi.BLACK_BRUSH), .lpszMenuName = null, .hInstance = instance, .lpfnWndProc = wndProc };

    const result = RegisterClass(&wnd_class);
    if (result == 0) {
        std.log.err("failed to register class", .{});
        return;
    }

    const handle = CreateWindow(
        windows_and_messaging.WINDOW_EX_STYLE{},
        class.ptr,
        title.ptr,
        windows_and_messaging.WS_OVERLAPPEDWINDOW,
        windows_and_messaging.CW_USEDEFAULT,
        windows_and_messaging.CW_USEDEFAULT,
        windows_and_messaging.CW_USEDEFAULT,
        windows_and_messaging.CW_USEDEFAULT,
        null, //parent,
        null, // menu,
        instance,
        null,
    ) orelse {
        std.log.err("failed to create window", .{});
        return;
    };

    _ = win32.graphics.dwm.DwmSetWindowAttribute(
        handle,
        win32.graphics.dwm.DWMWA_USE_IMMERSIVE_DARK_MODE,
        &if (try isLightMode()) win32.zig.FALSE else win32.zig.TRUE,
        @sizeOf(foundation.BOOL),
    );
    _ = ShowWindow(handle, windows_and_messaging.SW_SHOWDEFAULT);

    var message: windows_and_messaging.MSG = undefined;
    while (windows_and_messaging.GetMessageA(&message, null, 0, 0) == win32.zig.TRUE) {
        _ = windows_and_messaging.TranslateMessage(&message);
        _ = windows_and_messaging.DispatchMessageA(&message);
    }
}

const ImmersiveColorSet: [:0]const u8 = "ImmersiveColorSet\x00";
fn wndProc(
    hwnd: foundation.HWND,
    uMsg: u32,
    wparam: foundation.WPARAM,
    lparam: foundation.LPARAM,
) callconv(std.os.windows.WINAPI) foundation.LRESULT {
    switch (uMsg) {
        windows_and_messaging.WM_DESTROY => {
            windows_and_messaging.PostQuitMessage(0);
        },
        windows_and_messaging.WM_SETTINGCHANGE => {
            const name: [*:0]const u8 = @ptrFromInt(@as(usize, @bitCast(lparam)));

            const isImmersiveColorSet = for (0..18) |i| {
                if (name[i] != ImmersiveColorSet[i]) break false;
            } else true;

            if (isImmersiveColorSet) {
                if (isLightMode()) |lightMode| {
                    _ = win32.graphics.dwm.DwmSetWindowAttribute(
                        hwnd,
                        win32.graphics.dwm.DWMWA_USE_IMMERSIVE_DARK_MODE,
                        &if (lightMode) win32.zig.FALSE else win32.zig.TRUE,
                        @sizeOf(foundation.BOOL),
                    );
                } else |err| {
                    std.debug.print("{}", .{err});
                }
            }
        },
        else => return windows_and_messaging.DefWindowProcA(hwnd, uMsg, wparam, lparam),
    }

    return 0;
}

fn isLightMode() error{RegRead, RegNotFound, SystemError}!bool {
    var data_type: u32 = 0;
    var data: [4:0]u8 = [_:0]u8{0} ** 4;
    var length: u32 = 4;

    const code = win32.system.registry.RegGetValueA(
        win32.system.registry.HKEY_CURRENT_USER,
        "Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize",
        "SystemUsesLightTheme",
        win32.system.registry.RRF_RT_REG_DWORD,
        &data_type,
        @ptrCast(@alignCast(&data)),
        &length,
    );

    switch (code) {
        .NO_ERROR => return data[0] == 1,
        .ERROR_MORE_DATA => return error.RegRead,
        .ERROR_FILE_NOT_FOUND => return error.RegNotFound,
        else => return error.SystemError,
    }
}
