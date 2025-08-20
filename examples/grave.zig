const std = @import("std");
const utils = @import("utils");

var wait = std.atomic.Value(bool).init(true);

fn onSystemThemeChange(settings: *utils.graveyard.IUISettings3) void {
    std.debug.print("{any}\n", .{ settings.getColorValue(.Foreground) });
    wait.store(false, .release);
}

pub fn main() !void {
    // if (utils.graveyard.CoInitializeEx(null, .{
    //     .APARTMENTTHREADED = 1,
    //     .DISABLE_OLE1DDE = 1,
    // }) != utils.graveyard.S_OK) return error.CoInitializeFailure;
    // defer utils.graveyard.CoUninitialize();

    var ui_settings = try utils.graveyard.UISettings.init();
    defer _ = ui_settings.release();

    std.debug.print("{any}\n", .{ ui_settings.getColorValue(utils.graveyard.UIColorType.Foreground) });

    var handler = try utils.graveyard.TypedEventHandler(utils.graveyard.IUISettings3).init(std.heap.smp_allocator, onSystemThemeChange);
    defer handler.deinit();

    const handle = try ui_settings.colorValuesChanged(handler);

    while (wait.load(.acquire)) {
        std.time.sleep(std.time.ns_per_s * 1);
    }

    try ui_settings.removeColorValuesChanged(handle);
}
