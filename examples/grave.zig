const std = @import("std");
const win32 = @import("win32");

const utils = @import("utils");
const UISettings = utils.graveyard.UISettings;
const TypedEventHandler = utils.graveyard.TypedEventHandler;
const IUISettings3 = utils.graveyard.IUISettings3;

var wait = std.atomic.Value(bool).init(true);

fn onSystemThemeChange(settings: *utils.graveyard.IUISettings3) callconv(.C) void {
    std.debug.print("{any}\n", .{ settings.getColorValue(.Foreground) });
    wait.store(false, .release);
}

pub fn main() !void {
    // if (utils.graveyard.CoInitializeEx(null, .{
    //     .APARTMENTTHREADED = 1,
    //     .DISABLE_OLE1DDE = 1,
    // }) != utils.graveyard.S_OK) return error.CoInitializeFailure;
    // defer utils.graveyard.CoUninitialize();

    var ui_settings = try UISettings.init();
    defer _ = ui_settings.release();

    std.debug.print("{any}\n", .{ ui_settings.getColorValue(.Foreground) });

    var handler = try TypedEventHandler(IUISettings3).init(onSystemThemeChange);
    const handle = try ui_settings.colorValuesChanged(&handler);


    var msg: win32.ui.windows_and_messaging.MSG = undefined;
    while (win32.ui.windows_and_messaging.GetMessageW(&msg, null, 0, 0) > 0) {
        _ = win32.ui.windows_and_messaging.TranslateMessage(&msg);
        _ = win32.ui.windows_and_messaging.DispatchMessageW(&msg);
    }

    try ui_settings.removeColorValuesChanged(handle);
}
