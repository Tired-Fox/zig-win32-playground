const std = @import("std");
const process = std.process;

const InvokeCommand = struct {
    pub fn open(buffer: *std.ArrayList(u8)) !void  {
        try buffer.appendSlice("Invoke-Command -ScriptBlock {\n");
    }
    pub fn close(buffer: *std.ArrayList(u8)) !void  {
        try buffer.append('}');
    }
};

const Dictionary = struct {
    allocator: std.mem.Allocator,
    buffer: *std.ArrayList(u8),

    pub fn init(allocator: std.mem.Allocator, buffer: *std.ArrayList(u8)) !@This() {
        try buffer.appendSlice("$Dictionary = [System.Collections.Generic.Dictionary[String, String]]::New();\n");
        return .{
            .allocator = allocator,
            .buffer = buffer,
        };
    }

    pub  fn add(self: *@This(), name: []const u8, value: anytype) !void {
        const fmt = switch (@TypeOf(value)) {
            f32, comptime_float => "{d}",
            else => "{s}"
        };

        const temp = try std.fmt.allocPrint(self.allocator, "$Dictionary.Add('{s}', '" ++ fmt ++ "');\n", .{ name, value });
        defer self.allocator.free(temp);
        try self.buffer.appendSlice(temp);
    }
};

const Notifier = struct {
    allocator: std.mem.Allocator,
    buffer: *std.ArrayList(u8),

    pub fn init(allocator: std.mem.Allocator, buffer: *std.ArrayList(u8), app_id: []const u8) !@This() {
        const temp = try std.fmt.allocPrint(allocator, "$AppId = '{s}';\n", .{ app_id });
        defer allocator.free(temp);
        try buffer.appendSlice(temp);

        try buffer.appendSlice("$Notifier = [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]::CreateToastNotifier($AppId);\n");
        return .{
            .allocator = allocator,
            .buffer = buffer,
        };
    }

    pub fn show(self: *@This(), dictionary: Dictionary, sequence: u8, toast_notification: ToastNotification) !void {
        _ = dictionary;
        _ = toast_notification;

        try self.buffer.appendSlice("$ToastNotification.Data = [Windows.UI.Notifications.NotificationData]::New($Dictionary);\n");

        const temp = try std.fmt.allocPrint(self.allocator, "$ToastNotification.Data.SequenceNumber = {d};\n", .{ sequence });
        defer self.allocator.free(temp);
        try self.buffer.appendSlice(temp);

        try self.buffer.appendSlice("$Notifier.Show($ToastNotification);\n");
    }

    pub fn update(self: *@This(), dictionary: Dictionary, sequence: u8, tag: []const u8) !void {
        _ = dictionary;

        try self.buffer.appendSlice("$NotificationData = [Windows.UI.Notifications.NotificationData]::New($Dictionary);\n");

        var temp = try std.fmt.allocPrint(self.allocator, "$NotificationData.SequenceNumber = {d};\n", .{ sequence });
        defer self.allocator.free(temp);
        try self.buffer.appendSlice(temp);

        temp = try std.fmt.allocPrint(self.allocator, "$Notifier.Update($NotificationData, '{s}');\n", .{ tag });
        defer self.allocator.free(temp);
        try self.buffer.appendSlice(temp);
    }
};

const XmlToastTag = union(enum){
    close: void,
    attrs: Attrs,

    pub fn open(attrs: Attrs) @This() {
        return .{ .attrs = attrs };
    }

    pub const Attrs = struct {
        duration: ?enum { long, short } = null,
        scenario: ?enum { reminder, alarm, incoming_call, urgent } = null,
        /// Arguments passed to the application when it is activated by the toast.
        launch: ?[]const u8 = null,
        /// ISO 8601 standard timestamp
        displayTimestamp: ?[]const u8 = null,
        /// Whether to use styled buttons
        useButtonStyle: ?bool = null,
    };
};


const XmlImageAttrs = struct {
    /// + http://
    /// + https://
    /// + ms-appx://
    /// + ms-appdata:///local/
    /// + file:///
    src: []const u8,
    alt: ?[]const u8 = null,
    placement: ?enum{
        /// Very top of toast spaning the full width
        hero,
        /// Replaces app logo in toast
        app_logo_override
    } = null,
    /// Crop the image
    hint_crop: ?enum { circle } = null,
};

const XmlBindingTag = union(enum){
    close: void,
    template: []const u8,

    pub fn open(value: []const u8) @This() {
        return .{ .template = value };
    }
};

const Xml = struct {
    allocator: std.mem.Allocator,
    buffer: *std.ArrayList(u8),
    id: usize = 1,

    pub fn init(allocator: std.mem.Allocator, buffer: *std.ArrayList(u8)) !@This() {
        try buffer.appendSlice("$xml = '\n");

        return .{
            .allocator = allocator,
            .buffer = buffer,
        };
    }

    pub fn visual(self: *@This(), state: enum { open, close }) !void {
        switch (state) {
            .open => try self.buffer.appendSlice("  <visual>\n"),
            .close => try self.buffer.appendSlice("  </visual>\n"),
        }
    }

    pub fn image(self: *@This(), attrs: XmlImageAttrs) !void {
        self.id += 1;

        const temp = try std.fmt.allocPrint(self.allocator, "      <image id=\"{d}\"", .{ self.id });
        defer self.allocator.free(temp);
        try self.buffer.appendSlice(temp);

        try self.buffer.appendSlice("\n        src=\"");
        try self.buffer.appendSlice(attrs.src);
        try self.buffer.appendSlice("\"");

        if (attrs.alt) |alt| {
            try self.buffer.appendSlice("\n        alt=\"");
            try self.buffer.appendSlice(alt);
            try self.buffer.appendSlice("\"");
        }
        if (attrs.placement) |duration| {
            try self.buffer.appendSlice("\n        placement=\"");
            switch (duration) {
                .hero => try self.buffer.appendSlice("hero"),
                .app_logo_override => try self.buffer.appendSlice("appLogoOverride"),
            }
            try self.buffer.appendSlice("\"");
        }
        if (attrs.hint_crop) |crop|  {
            try self.buffer.appendSlice("\n        hint-crop=\"");
            switch (crop) {
                .circle => try self.buffer.appendSlice("circle"),
            }
            try self.buffer.appendSlice("\"");
        }
        try self.buffer.appendSlice("/>\n");
    }

    pub fn binding(self: *@This(), state: XmlBindingTag) !void {
        switch (state) {
            .template => |value| {
                const temp = try std.fmt.allocPrint(self.allocator, "    <binding template=\"{s}\">\n", .{ value });
                defer self.allocator.free(temp);
                try self.buffer.appendSlice(temp);
            },
            .close => try self.buffer.appendSlice("    </binding>\n"),
        }
    }

    pub fn toast(self: *@This(), state: XmlToastTag) !void {
        switch (state) {
            .close =>  try self.buffer.appendSlice("      </toast>\n';\n"),
            .attrs => |attrs| {
                var temp: []const u8 = undefined;
                try self.buffer.appendSlice("      <toast");
                if (attrs.scenario) |scenario| {
                    switch (scenario) {
                        .reminder => try self.buffer.appendSlice(" scenario=\"reminder\""),
                        .alarm => try self.buffer.appendSlice(" scenario=\"alarm\""),
                        .incoming_call, => try self.buffer.appendSlice(" scenario=\"incomingCall\"") ,
                        .urgent => try self.buffer.appendSlice(" scenario=\"urgent\""),
                    }
                }
                if (attrs.duration) |duration| {
                    switch (duration) {
                        .long => try self.buffer.appendSlice(" duration=\"long\""),
                        .short => try self.buffer.appendSlice(" duration=\"short\""),
                    }
                }
                if (attrs.displayTimestamp) |timestamp|  {
                    temp = try std.fmt.allocPrint(self.allocator, " displayTimestamp=\"{s}\"", .{ timestamp });
                    defer self.allocator.free(temp);
                    try self.buffer.appendSlice(temp);
                }
                if (attrs.launch) |launch|  {
                    temp = try std.fmt.allocPrint(self.allocator, " launch=\"{s}\"", .{ launch });
                    defer self.allocator.free(temp);
                    try self.buffer.appendSlice(temp);
                }
                if (attrs.useButtonStyle orelse false) {
                    try self.buffer.appendSlice(" useButtonStyle=\"true\"");
                } else { 
                    try self.buffer.appendSlice(" useButtonStyle=\"false\"");
                }
                try self.buffer.appendSlice(">\n");
            }
        }
    }

    pub fn text(self: *@This(), content: []const u8, hint_style: ?[]const u8) !void { 
        self.id += 1;

        var temp = try std.fmt.allocPrint(self.allocator, "      <text id=\"{d}\"", .{ self.id });
        defer self.allocator.free(temp);
        try self.buffer.appendSlice(temp);

        if (hint_style) |style| {
            try self.buffer.appendSlice(" hint-style=\"");
            try self.buffer.appendSlice(style);
            try self.buffer.appendSlice("\"");
        }

        temp = try std.fmt.allocPrint(self.allocator, ">{s}</text>\n", .{ content });
        defer self.allocator.free(temp);
        try self.buffer.appendSlice(temp);
    }

    pub fn progress(self: *@This(), title: bool, override: bool) !void { 
        try self.buffer.appendSlice("      <progress\n");
        if (title) {
            try self.buffer.appendSlice("        title=\"{progressTitle}\"\n");
        }
        if (override) {
            try self.buffer.appendSlice("        valueStringOverride=\"{progressValueString}\"\n");
        }

        try self.buffer.appendSlice(
            \\        value="{progressValue}"
            \\        status="{progressStatus}"/>
            \\
        );
    }

    pub fn close(self: *@This()) !void {
        try self.buffer.appendSlice(
            \\    </binding>
            \\  </visual>
            \\</toast>
            \\';
            \\
        );
    }
};

const XmlDocument = struct {
    allocator: std.mem.Allocator,
    buffer: *std.ArrayList(u8),

    pub fn init(allocator: std.mem.Allocator, buffer: *std.ArrayList(u8)) !@This() {
        try buffer.appendSlice("$XmlDocument = [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime]::New();\n");
        return .{
            .allocator = allocator,
            .buffer = buffer,
        };
    }

    pub fn loadXml(self: *@This(), xml: Xml) !void {
        _ = xml;
        try self.buffer.appendSlice("$XmlDocument.loadXml($xml);\n");
    }
};

const ToastNotification = struct {
    pub fn init(allocator: std.mem.Allocator, buffer: *std.ArrayList(u8), xml_document: XmlDocument, tag: []const u8) !@This() {
        _  = xml_document;

        try buffer.appendSlice(
            \\$ToastNotification = [Windows.UI.Notifications.ToastNotification, Windows.UI.Notifications, ContentType = WindowsRuntime]::New($XmlDocument);
            \\
        );

        const temp = try std.fmt.allocPrint(allocator, "$ToastNotification.Tag = '{s}';\n", .{ tag });
        defer allocator.free(temp);
        try buffer.appendSlice(temp);
        return .{};
    }
};

const Script = struct {
    allocator: std.mem.Allocator,
    buffer: std.ArrayList(u8),

    pub fn init(allocator: std.mem.Allocator) @This() {
        return .{
            .allocator = allocator,
            .buffer = std.ArrayList(u8).init(allocator),
        };
    }

    pub fn deinit(self: *@This()) void {
        self.buffer.deinit();
    }

    pub fn execute(self: *@This()) !void {
        const result = try process.Child.run(.{ .allocator = self.allocator, .argv = &.{ "powershell", "-c", self.buffer.items } });
        self.allocator.free(result.stdout);
        self.allocator.free(result.stderr);
    }

    pub fn startCommand(self: *@This()) !void {
        try self.buffer.appendSlice("Invoke-Command -ScriptBlock {\n");
    }

    pub fn endCommand(self: *@This()) !void {
        try self.buffer.appendSlice("}");
    }

    pub fn xml(self: *@This()) !Xml {
        return try Xml.init(self.allocator, &self.buffer);
    }

    pub fn dictionary(self: *@This()) !Dictionary {
        return try Dictionary.init(self.allocator, &self.buffer);
    }

    pub fn xml_document(self: *@This()) !XmlDocument {
        return try XmlDocument.init(self.allocator, &self.buffer);
    }

    pub fn toast_notification(self: *@This(), document: XmlDocument, tag: []const u8) !ToastNotification {
        return try ToastNotification.init(self.allocator, &self.buffer, document, tag);
    }

    pub fn notifier(self: *@This(), app_id: []const u8) !Notifier {
        return try Notifier.init(self.allocator, &self.buffer, app_id);
    }
};

const Progress = union(enum) {
    intermediate: void,
    value: f32,
    fn progress(v: f32) @This() {
        return .{ .value = v };
    }
};

const Config = struct {
    title: []const u8,
    body: ?[]const u8 = null,
    logo: ?struct {
        src: []const u8,
        alt: []const u8,
        crop: bool = false,
    } = null,
    hero: ?struct{
        src: []const u8,
        alt: []const u8,
    } = null,
    progress: ?struct {
        value: Progress,
        status: []const u8,
        title: ?[]const u8 = null,
        override: ?[]const u8 = null,
    } = null,
};

const Update = struct {
    title: ?[]const u8 = null,
    body: ?[]const u8 = null,
    progress: ?struct {
        value: ?Progress = null,
        status: ?[]const u8 = null,
        title: ?[]const u8 = null,
        override: ?[]const u8 = null,
    } = null,
};

const Notification = struct {
    config: Config,
    tag: []const u8,
    app_id: []const u8,

    fn send(alloc: std.mem.Allocator, app_id: ?[]const u8, tag: []const u8, config: Config) !@This() {
        var script = Script.init(alloc);
        defer script.deinit();

        try script.startCommand();

        var xml = try script.xml();
        try xml.toast(.open(.{ .scenario = .reminder }));
        try xml.visual(.open);
        try xml.binding(.open("ToastGeneric"));
                    
        try xml.text("{notificationTitle}", "title");
        if (config.body != null) {
            try xml.text("{notificationBody}", null);
        }
        if (config.progress) |progress| {
            try xml.progress(progress.title != null, progress.override != null);
        }

        if (config.hero) |hero| {
            try xml.image(.{
                .src = hero.src,
                .alt = hero.alt,
                .placement = .hero,
            });
        }

        if (config.logo) |logo| {
            try xml.image(.{
                .src = logo.src,
                .alt = logo.alt,
                .placement = .app_logo_override,
                .hint_crop = if (logo.crop) .circle else null,
            });
        }

        try xml.binding(.close);
        try xml.visual(.close);
        try xml.toast(.close);

        var dictionary = try script.dictionary();
        try dictionary.add("notificationTitle", config.title);

        if (config.body) |body| try dictionary.add("notificationBody", body);

        if (config.progress) |progress| {
            switch (progress.value) {
                .intermediate => try dictionary.add("progressValue", "intermediate"),
                .value => |v| try dictionary.add("progressValue", v),
            }
            try dictionary.add("progressStatus", progress.status);
            if (progress.title) |title| try dictionary.add("progressTitle", title);
            if (progress.override) |override| try dictionary.add("progressValueString", override);
        }

        var xml_document = try script.xml_document();
        try xml_document.loadXml(xml);

        const toast_notification = try script.toast_notification(xml_document, tag);

        var notifier = try script.notifier(app_id orelse "{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\\WindowsPowerShell\\v1.0\\powershell.exe");
        try notifier.show(dictionary, 1, toast_notification);

        try script.endCommand();

        try script.execute();

        return .{
            .tag = tag,
            .app_id = app_id orelse "{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\\WindowsPowerShell\\v1.0\\powershell.exe",
            .config = config
        };
    }

    pub fn update(self: *const @This(), alloc: std.mem.Allocator, config: Update) !void {
        var script = Script.init(alloc);
        defer script.deinit();

        try script.startCommand();
        
        var dictionary = try script.dictionary();
        if (config.title) |title| {
            try dictionary.add("notificationTitle", title);
        }

        if (config.body) |body| {
            if (self.config.body == null) return error.NotificationBodyNotConfigured;
            try dictionary.add("notificationBody", body);
        }

        if (config.progress) |progress| {
            if (self.config.progress == null) return error.NotificationProgressNotConfigured;
            if (progress.title) |title| {
                if (self.config.progress.?.title == null) return error.NotificationProgressTitleNotConfigured;
                try dictionary.add("progressTitle", title);
            }

            if (progress.value) |value| {
                switch (value) {
                    .intermediate => try dictionary.add("progressValue", "intermediate"),
                    .value => |v| try dictionary.add("progressValue", v),
                }
            }

            if (progress.status) |status| {
                try dictionary.add("progressStatus", status);
            }

            if (progress.override) |override| {
                if (self.config.progress.?.override == null) return error.NotificationProgressValueStringNotConfigured;
                try dictionary.add("progressValueString", override);
            }
        }

        var notifier = try script.notifier(self.app_id);
        try notifier.update(dictionary, 2, self.tag);

        try script.endCommand();

        try script.execute();
    }
};

pub fn main() !void {
    const notification = try Notification.send(std.heap.smp_allocator, null, "zig-test-notif", .{
        .title="Updating Genshin Impact",
        .body="Download and install the latest and jump back into the action",
        .hero = .{
            .src = "file:///C:\\Users\\dorkd\\Repo\\Zig\\zig-win32-playground\\examples\\album_cover.jpg",
            .alt = "Banner"
        },
        .logo = .{
            .src = "file:///C:\\Users\\dorkd\\Repo\\Zig\\zig-win32-playground\\examples\\progress_logo.png",
            .alt = "HoYo",
            .crop = true,
        },
        .progress = .{
            .value = .progress(0.0),
            .status = "Downloading...",
        }
    });

    inline for (1..10) |i| {
        try notification.update(
            std.heap.smp_allocator,
            .{
                .progress = .{
                    .value = .progress(@as(f32, @floatFromInt(i)) * 0.1),
                    .status = if (i > 5) "Installing..." else "Downloading..."
                }
            }
        );
        std.time.sleep(500 * std.time.ns_per_ms);
    }

    try notification.update(
        std.heap.smp_allocator,
        .{
            .progress = .{
                .value = .progress(1.0),
                .status = "Completed",
            }
        }
    );
}
