const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    const ui_settings = try utils.graveyard.UISettings.init();
    std.debug.print("{any}\n", .{ ui_settings.getColorValue(utils.graveyard.UIColorType.Foreground) });
}
