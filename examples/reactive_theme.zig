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

const isLightTheme = @import("utils").theme.isLightTheme;

var brush: ?win32.graphics.gdi.HGDIOBJ = undefined;

pub fn main() !void {
    const class: [:0]align(1) const u8 = "win-win-simple-1";
    const title: [:0]const u8 = "title goes here";

    const instance = GetModuleHandle(null);
    const wnd_class = WNDCLASS{
        .lpszClassName = class.ptr,
        .style = WNDCLASS_STYLES{ .HREDRAW = 1, .VREDRAW = 1 },
        .cbClsExtra = 0,
        .cbWndExtra = 0,
        .hIcon = null,
        .hCursor = null,
        .hbrBackground = null,
        .lpszMenuName = null,
        .hInstance = instance,
        .lpfnWndProc = wndProc,
    };

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

    const lightTheme = try isLightTheme();
    brush = win32.graphics.gdi.GetStockObject(if (lightTheme) win32.graphics.gdi.LTGRAY_BRUSH else win32.graphics.gdi.BLACK_BRUSH);
    defer {
        if (brush) |hbrush| _ = win32.graphics.gdi.DeleteObject(hbrush);
    }

    _ = win32.graphics.dwm.DwmSetWindowAttribute(
        handle,
        win32.graphics.dwm.DWMWA_USE_IMMERSIVE_DARK_MODE,
        &if (lightTheme) win32.zig.FALSE else win32.zig.TRUE,
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
        windows_and_messaging.WM_ERASEBKGND => {
            const hdc: win32.graphics.gdi.HDC = @ptrFromInt(wparam);
            var rect: win32.foundation.RECT = undefined;
            _ = windows_and_messaging.GetClientRect(hwnd, &rect);

            if (brush) |hbrush| {
                _ = win32.graphics.gdi.FillRect(hdc, &rect, hbrush);
            }
            return 1;
        },
        windows_and_messaging.WM_SETTINGCHANGE => {
            // This message is sent when a setting has changed and the OS
            // notifies the application/window. The lpaaram is a pointer to
            // a string representing what was changed. This can be a path to
            // the registry key or a constant like `ImmersiveColorSet`, `Policy`, etc.
            const name: [*:0]const u8 = @ptrFromInt(@as(usize, @bitCast(lparam)));

            // In this case name should equal "ImmersiveColorSet"
            // which indicates that the system theme has changed in some way.
            const isImmersiveColorSet = for (0..18) |i| {
                if (name[i] != ImmersiveColorSet[i]) break false;
            } else true;

            if (isImmersiveColorSet) {
                // Get whether the system is using a light theme
                // Computer\\HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize -> AppsUseLightTheme
                if (isLightTheme()) |lightTheme| {
                    // Update the window immersive dark mode flag
                    // based on the system settings
                    _ = win32.graphics.dwm.DwmSetWindowAttribute(
                        hwnd,
                        win32.graphics.dwm.DWMWA_USE_IMMERSIVE_DARK_MODE,
                        &if (lightTheme) win32.zig.FALSE else win32.zig.TRUE,
                        @sizeOf(foundation.BOOL),
                    );

                    if (brush) |hbrush| _ = win32.graphics.gdi.DeleteObject(hbrush);
                    brush = win32.graphics.gdi.GetStockObject(if (lightTheme) win32.graphics.gdi.LTGRAY_BRUSH else win32.graphics.gdi.BLACK_BRUSH);
                    _ = win32.graphics.gdi.RedrawWindow(hwnd, null, null, win32.graphics.gdi.REDRAW_WINDOW_FLAGS{ .INVALIDATE = 1, .ERASE = 1 });

                } else |err| {
                    std.debug.print("{}", .{err});
                }
                return 1;
            } else {
                return windows_and_messaging.DefWindowProcA(hwnd, uMsg, wparam, lparam);
            }
        },
        else => return windows_and_messaging.DefWindowProcA(hwnd, uMsg, wparam, lparam),
    }

    return 0;
}
