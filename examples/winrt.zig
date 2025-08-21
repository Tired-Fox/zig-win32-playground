const std = @import("std");
const win32 = @import("win32");

const winrt = @import("utils").winrt;
const TypedEventHandler = winrt.foundation.TypedEventHandler;
const UISettings = winrt.ui.view_management.UISettings;
const IInspectable = winrt.IInspectable;

const XmlDocument = winrt.data.xml.dom.XmlDocument;

const HSTRING = winrt.HSTRING;
const WindowsCreateString = winrt.WindowsCreateString;
const WindowsDeleteString = winrt.WindowsDeleteString;

// var wait = std.atomic.Value(bool).init(true);

// fn onSystemThemeChange(settings: *UISettings, _: ?*anyopaque) callconv(.C) void {
//     const fg = settings.getColorValue(.foreground) catch return;
//     if (fg.b > 0) {
//         std.debug.print("\x1b[40;38;2;{d};{d};{d}m DARK \x1b[0m\n", .{ fg.r, fg.g, fg.b });
//     } else {
//         std.debug.print("\x1b[47;38;2;{d};{d};{d}m LIGHT \x1b[0m\n", .{ fg.r, fg.g, fg.b });
//     }
//     wait.store(false, .release);
// }

pub fn main() !void {
    // var ui_settings = try UISettings.init();
    // defer ui_settings.deinit();
    //
    // std.debug.print("Current System Foreground Color: {any}\n", .{ ui_settings.getColorValue(.foreground) });
    //
    // var handler = try TypedEventHandler(UISettings, IInspectable).init(onSystemThemeChange);
    // const handle = try ui_settings.colorValuesChanged(&handler);
    //
    // // Wait for color change to be detected
    // std.debug.print("Waiting for system color change...\n", .{});
    // while (wait.load(.acquire)) {
    //     std.time.sleep(std.time.ns_per_s * 1);
    // }
    //
    // try ui_settings.removeColorValuesChanged(handle);

    const xml_document = try XmlDocument.init();
    defer xml_document.deinit();

    const xml: [:0]const u16 = std.unicode.utf8ToUtf16LeStringLiteral(
        \\<toast launch="">
        \\    <visual>
        \\        <binding template="ToastGeneric">
        \\            <text id="0" hint-style="title">Hello, world!</text>
        \\            <text id="1">Text notification</text>
        \\        </binding>
        \\    </visual>
        \\</toast>
    );
    const xml_hstring: ?HSTRING = try WindowsCreateString(xml);
    defer WindowsDeleteString(xml_hstring);
    try xml_document.load_xml(xml_hstring.?);
}
