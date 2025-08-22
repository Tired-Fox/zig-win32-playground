const std = @import("std");
const win32 = @import("win32");

const winrt = @import("utils").winrt;
const TypedEventHandler = winrt.foundation.TypedEventHandler;
const UISettings = winrt.ui.view_management.UISettings;
const IInspectable = winrt.IInspectable;

const XmlDocument = winrt.data.xml.dom.XmlDocument;
const XmlElement = winrt.data.xml.dom.XmlElement;
const IXmlNode = winrt.data.xml.dom.IXmlNode;
const ToastNotificationManager = winrt.ui.notifications.ToastNotificationManager;
const ToastNotification = winrt.ui.notifications.ToastNotification;
const IVectorView = winrt.foundation.collections.IVectorView;

const HSTRING = winrt.HSTRING;
const WindowsCreateString = winrt.WindowsCreateString;
const WindowsDeleteString = winrt.WindowsDeleteString;

const Signature = winrt.core.Signature;

// var wait = std.atomic.Value(bool).init(true);
//
// fn onSystemThemeChange(_: ?*anyopaque, settings: *UISettings, _: *IInspectable) callconv(.C) void {
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
        \\<toast>
        \\    <visual>
        \\        <binding>
        \\        </binding>
        \\    </visual>
        \\</toast>
    );
    try xml_document.loadXml(xml);

    const text_node = try xml_document.createElement(std.unicode.utf8ToUtf16LeStringLiteral("text"));
    defer _ = text_node.release();

    const bindings = try xml_document.getElementsByTagName(std.unicode.utf8ToUtf16LeStringLiteral("binding"));
    if (bindings.length() > 0) {
        const first: ?*IXmlNode = bindings.item(0);

        if (first) |node| {
            const binding: *XmlElement = try node.queryInterface(XmlElement);
            try binding.setAttribute(
                std.unicode.utf8ToUtf16LeStringLiteral("template"),
                std.unicode.utf8ToUtf16LeStringLiteral("ToastGeneric"),
            );

            {
                var title = try text_node.cloneNode(false);
                defer _ = title.release();

                const tel: *XmlElement = try title.queryInterface(XmlElement);
                try tel.setAttribute(
                    std.unicode.utf8ToUtf16LeStringLiteral("hint-style"),
                    std.unicode.utf8ToUtf16LeStringLiteral("title"),
                );

                const title_text_node = try xml_document.createTextNode(std.unicode.utf8ToUtf16LeStringLiteral("Zig Windows Runtime"));
                defer _ = title_text_node.release();

                _ = try title.appendChild(@ptrCast(@alignCast(title_text_node)));
                _ = try binding.appendChild(title);
            }

            {
                var body = try text_node.cloneNode(false);
                defer _ = body.release();

                const body_text_node = try xml_document.createTextNode(std.unicode.utf8ToUtf16LeStringLiteral(
                    "No Powershell needed!"
                ));
                defer _ = body_text_node.release();

                _ = try body.appendChild(@ptrCast(@alignCast(body_text_node)));
                _ = try binding.appendChild(body);
            }
            // _ = try el.appendChild(title);
        }
    }

    {
        const built_xml = try std.unicode.utf16LeToUtf8Alloc(std.heap.smp_allocator, try xml_document.getXml());
        defer std.heap.smp_allocator.free(built_xml);
        std.debug.print("[XML]\n{s}\n", .{built_xml});
    }

    const notification = try ToastNotification.createToastNotification(xml_document);
    defer _ = notification.release();

    const POWERSHELL: [:0]const u16 = std.unicode.utf8ToUtf16LeStringLiteral("{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\\WindowsPowerShell\\v1.0\\powershell.exe");

    var notifier = try ToastNotificationManager.createToastNotifierWithId(POWERSHELL);
    defer _ = notifier.release();

    try notifier.show(notification);
}
