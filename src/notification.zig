const std = @import("std");
const process = std.process;

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

    pub fn add(self: *@This(), name: []const u8, value: anytype) !void {
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
        const temp = try std.fmt.allocPrint(allocator, "$AppId = '{s}';\n", .{app_id});
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

        const temp = try std.fmt.allocPrint(self.allocator, "$ToastNotification.Data.SequenceNumber = {d};\n", .{sequence});
        defer self.allocator.free(temp);
        try self.buffer.appendSlice(temp);

        try self.buffer.appendSlice("$Notifier.Show($ToastNotification);\n");
    }

    pub fn update(self: *@This(), dictionary: Dictionary, sequence: u8, tag: []const u8) !void {
        _ = dictionary;

        try self.buffer.appendSlice("$NotificationData = [Windows.UI.Notifications.NotificationData]::New($Dictionary);\n");

        var temp = try std.fmt.allocPrint(self.allocator, "$NotificationData.SequenceNumber = {d};\n", .{sequence});
        defer self.allocator.free(temp);
        try self.buffer.appendSlice(temp);

        temp = try std.fmt.allocPrint(self.allocator, "$Notifier.Update($NotificationData, '{s}');\n", .{tag});
        defer self.allocator.free(temp);
        try self.buffer.appendSlice(temp);
    }
};

const XmlToastTag = union(enum) {
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
    placement: ?enum {
        /// Very top of toast spaning the full width
        hero,
        /// Replaces app logo in toast
        app_logo_override
    } = null,
    /// Crop the image
    hint_crop: ?enum { circle } = null,
};

const XmlBindingTag = union(enum) {
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

    pub fn actions(self: *@This(), state: enum { open, close }) !void {
        switch (state) {
            .open => try self.buffer.appendSlice("  <actions>\n"),
            .close => try self.buffer.appendSlice("  </actions>\n"),
        }
    }

    pub fn visual(self: *@This(), state: enum { open, close }) !void {
        switch (state) {
            .open => try self.buffer.appendSlice("  <visual>\n"),
            .close => try self.buffer.appendSlice("  </visual>\n"),
        }
    }

    pub fn image(self: *@This(), attrs: XmlImageAttrs) !void {
        self.id += 1;

        const temp = try std.fmt.allocPrint(self.allocator, "      <image id=\"{d}\"", .{self.id});
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
        if (attrs.hint_crop) |crop| {
            try self.buffer.appendSlice("\n        hint-crop=\"");
            switch (crop) {
                .circle => try self.buffer.appendSlice("circle"),
            }
            try self.buffer.appendSlice("\"");
        }
        try self.buffer.appendSlice("/>\n");
    }

    pub fn action(self: *@This(), a: Action) !void {
        switch (a) {
            .input => |attrs| {
                try self.buffer.appendSlice("    <input type=\"text\" id=\"");
                try self.buffer.appendSlice(attrs.id);
                try self.buffer.append('"');

                if (attrs.place_holder_content) |placeholder| {
                    try self.buffer.appendSlice(" placeHolderContent=\"");
                    try self.buffer.appendSlice(placeholder);
                    try self.buffer.append('"');
                }

                if (attrs.title) |title| {
                    try self.buffer.appendSlice(" title=\"");
                    try self.buffer.appendSlice(title);
                    try self.buffer.append('"');
                }

                try self.buffer.appendSlice("/>");
            },
            .select => |config| {
                try self.buffer.appendSlice("    <input type=\"selection\" id=\"");
                try self.buffer.appendSlice(config.id);
                try self.buffer.append('"');

                if (config.title) |title| {
                    try self.buffer.appendSlice(" title=\"");
                    try self.buffer.appendSlice(title);
                    try self.buffer.append('"');
                }
                try self.buffer.appendSlice(">\n");

                for (config.items) |item| {
                    try self.buffer.appendSlice("      <selection id=\"");
                    try self.buffer.appendSlice(item.id);
                    try self.buffer.appendSlice("\" content=\"");
                    try self.buffer.appendSlice(item.content);
                    try self.buffer.appendSlice("\"/>\n");
                }
                try self.buffer.appendSlice("    </input>\n");
            },
            .button => |attrs| {
                try self.buffer.appendSlice(
                    \\    <action
                    \\      content="
                );
                try self.buffer.appendSlice(attrs.content);
                try self.buffer.appendSlice(
                    \\"
                    \\      arguments="
                );
                try self.buffer.appendSlice(attrs.arguments);
                try self.buffer.append('"');

                if (attrs.activation_type) |atype| {
                    switch (atype) {
                        .foreground => try self.buffer.appendSlice("\n      activationType=\"foreground\""),
                        .background => try self.buffer.appendSlice("\n      activationType=\"background\""),
                        .protocol => try self.buffer.appendSlice("\n      activationType=\"protocol\""),
                    }
                }
                if (attrs.after_activation_behavior) |behavior| {
                    switch (behavior) {
                        .default => try self.buffer.appendSlice("\n      afterActivationBehavior=\"default\""),
                        .pending_update => try self.buffer.appendSlice("\n      afterActivationBehavior=\"pendingUpdate\""),
                    }
                }
                if (attrs.placement) |placement| {
                    switch (placement) {
                        .context_menu => try self.buffer.appendSlice("\n      placement=\"contextMenu\""),
                    }
                }
                if (attrs.hint_button_style) |button_style| {
                    switch (button_style) {
                        .success => try self.buffer.appendSlice("\n      hint-buttonStyle=\"Success\""),
                        .critical => try self.buffer.appendSlice("\n      hint-buttonStyle=\"Critical\""),
                    }
                }
                if (attrs.image_uri) |uri| {
                    try self.buffer.appendSlice("\n      imageUri=\"");
                    try self.buffer.appendSlice(uri);
                    try self.buffer.append('"');
                }
                if (attrs.hint_input_id) |id| {
                    try self.buffer.appendSlice("\n      hint-inputId=\"");
                    try self.buffer.appendSlice(id);
                    try self.buffer.append('"');
                }
                if (attrs.hint_tool_tip) |tip| {
                    try self.buffer.appendSlice("\n      hint-toolTip=\"");
                    try self.buffer.appendSlice(tip);
                    try self.buffer.append('"');
                }
                try self.buffer.appendSlice("/>\n");
            }
        }
    }

    pub fn binding(self: *@This(), state: XmlBindingTag) !void {
        switch (state) {
            .template => |value| {
                const temp = try std.fmt.allocPrint(self.allocator, "    <binding template=\"{s}\">\n", .{value});
                defer self.allocator.free(temp);
                try self.buffer.appendSlice(temp);
            },
            .close => try self.buffer.appendSlice("    </binding>\n"),
        }
    }

    pub fn toast(self: *@This(), state: XmlToastTag) !void {
        switch (state) {
            .close => try self.buffer.appendSlice("      </toast>\n';\n"),
            .attrs => |attrs| {
                var temp: []const u8 = undefined;
                try self.buffer.appendSlice("      <toast");
                if (attrs.scenario) |scenario| {
                    switch (scenario) {
                        .reminder => try self.buffer.appendSlice(" scenario=\"reminder\""),
                        .alarm => try self.buffer.appendSlice(" scenario=\"alarm\""),
                        .incoming_call,
                        => try self.buffer.appendSlice(" scenario=\"incomingCall\""),
                        .urgent => try self.buffer.appendSlice(" scenario=\"urgent\""),
                    }
                }
                if (attrs.duration) |duration| {
                    switch (duration) {
                        .long => try self.buffer.appendSlice(" duration=\"long\""),
                        .short => try self.buffer.appendSlice(" duration=\"short\""),
                    }
                }
                if (attrs.displayTimestamp) |timestamp| {
                    temp = try std.fmt.allocPrint(self.allocator, " displayTimestamp=\"{s}\"", .{timestamp});
                    defer self.allocator.free(temp);
                    try self.buffer.appendSlice(temp);
                }
                if (attrs.launch) |launch| {
                    temp = try std.fmt.allocPrint(self.allocator, " launch=\"{s}\"", .{launch});
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

        var temp = try std.fmt.allocPrint(self.allocator, "      <text id=\"{d}\"", .{self.id});
        defer self.allocator.free(temp);
        try self.buffer.appendSlice(temp);

        if (hint_style) |style| {
            try self.buffer.appendSlice(" hint-style=\"");
            try self.buffer.appendSlice(style);
            try self.buffer.appendSlice("\"");
        }

        temp = try std.fmt.allocPrint(self.allocator, ">{s}</text>\n", .{content});
        defer self.allocator.free(temp);
        try self.buffer.appendSlice(temp);
    }

    pub fn audio(self: *@This(), sound: Audio, loop: ?bool) !void {
        try self.buffer.appendSlice("      <audio");
        switch (sound) {
            .silent, .custom_uri => try self.buffer.appendSlice(" silent=\"true\"/>\n"),
            else => {
                try self.buffer.appendSlice(" src=\"");
                try self.buffer.appendSlice(sound.source());
                try self.buffer.appendSlice("\"");
                if (loop orelse false) {
                    try self.buffer.appendSlice(" loop=\"true\"");
                } else {
                    try self.buffer.appendSlice(" loop=\"false\"");
                }
                try self.buffer.appendSlice("/>\n");
            }
        }
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

const MediaPlayer = struct {
    allocator: std.mem.Allocator,
    buffer: *std.ArrayList(u8),

    pub fn init(allocator: std.mem.Allocator, buffer: *std.ArrayList(u8)) !@This() {
        try buffer.appendSlice("$MediaPlayer = [Windows.Media.Playback.MediaPlayer, Windows.Media, ContentType = WindowsRuntime]::New();\n");
        return .{
            .allocator = allocator,
            .buffer = buffer,
        };
    }

    pub fn createFromUri(self: *@This(), uri: []const u8) !void {
        try self.buffer.appendSlice("$MediaPlayer.Source = [Windows.Media.Core.MediaSource]::CreateFromUri('");
        try self.buffer.appendSlice(uri);
        try self.buffer.appendSlice("');\n");
    }

    pub fn play(self: *@This()) !void {
        try self.buffer.appendSlice("$MediaPlayer.Play();\n");
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
        _ = xml_document;

        try buffer.appendSlice(
            \\$ToastNotification = [Windows.UI.Notifications.ToastNotification, Windows.UI.Notifications, ContentType = WindowsRuntime]::New($XmlDocument);
            \\
        );

        const temp = try std.fmt.allocPrint(allocator, "$ToastNotification.Tag = '{s}';\n", .{tag});
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

    pub fn media_player(self: *@This()) !MediaPlayer {
        return try MediaPlayer.init(self.allocator, &self.buffer);
    }
};

pub const Progress = union(enum) {
    intermediate: void,
    value: f32,
    pub fn progress(v: f32) @This() {
        return .{ .value = v };
    }
};

pub const Action = union(enum) {
    input: InputAction,
    select: SelectAction,
    button: ButtonAction,

    pub fn Input(config: InputAction) @This() {
        return .{ .input = config };
    }
    pub fn Select(config: SelectAction) @This() {
        return .{ .select = config };
    }
    pub fn Button(config: ButtonAction) @This() {
        return .{ .button = config };
    }

    pub const SelectAction = struct {
        /// The id associated with the selection
        id: []const u8,
        items: []const Selection,
        /// Text displayed as a label for the input
        title: ?[]const u8 = null,
    };

    pub const ButtonAction = struct {
        /// Content displayed on the button
        content: []const u8 = "",
        /// App-defined string of arguments that the app will later receive
        /// if the user clicks the button
        arguments: []const u8,

        /// Decides the type of activation that will be used when the user interacts
        /// with a specific action
        activation_type: ?ActiviationType = null,
        /// Specifies the behavior that the toast should use when the user takes action
        after_activation_behavior: ?ActivationBehavior = null,
        /// When set to "contextMenu" the action becomes a context menu action
        /// added to the toast notification's context menu. (right-click/more menu)
        placement: ?enum { context_menu } = null,
        /// The uri of the image source for a toast button icon. These icons are `white
        /// transparent 16x16 pixel images at 100% scaling` and should have `no padding`
        /// included in the image itself.
        ///
        /// If you choose to provide icons on a toast notification, you must provide
        /// icons for ALL of your buttons as it transforms the style of your buttons
        /// into icon buttons.
        ///
        /// Use the following formats:
        /// + http://
        /// + https://
        /// + ms-appx:///
        /// + ms-appdata:///local/
        /// + file:///
        image_uri: ?[]const u8 = null,
        /// Set to the id of an input to position the button beside the input
        hint_input_id: ?[]const u8 = null,
        /// The button style. `useButtonStyle` must be set to true on the `toast`
        ///
        /// + Success - The button is green
        /// + Critical - The button is red
        hint_button_style: ?ButtonStyle = null,
        /// The tooltip for a button, if the button has an empty content string
        hint_tool_tip: ?[]const u8 = null,
    };

    pub const InputAction = struct {
        /// The id associated with the input
        id: []const u8,
        /// The placeholder displayed for text input
        place_holder_content: ?[]const u8 = null,
        /// Text displayed as a label for the input
        title: ?[]const u8 = null,
    };

    pub const Selection = struct {
        /// Id of the selection item
        id: []const u8,
        /// Content of the selection item
        content: []const u8
    };

    pub const ButtonStyle = enum {
        /// Green
        success,
        /// Red
        critical,
    };

    pub const ActiviationType = enum {
        /// [Default] Your foreground app is launched
        foreground,
        /// Your corresponding background task is triggered
        background,
        /// Launch a different app using protocol activation
        protocol,
    };

    pub const ActivationBehavior = enum {
        /// [Default] The toast will be dismissed when the user takes action
        default,
        /// After the user clicks a button on your toast, the notification
        /// will remain present, in a "pending update" visual state.
        ///
        /// The background task should update the toast so that the user doesn't
        /// see the "pending update" state for too long.
        pending_update,
    };
};

pub const Audio = union(enum) {
    custom_uri: []const u8,

    silent: void,
    default: void,
    im: void,
    mail: void,
    reminder: void,
    sms: void,
    looping_alarm: void,
    looping_alarm2: void,
    looping_alarm3: void,
    looping_alarm4: void,
    looping_alarm5: void,
    looping_alarm6: void,
    looping_alarm7: void,
    looping_alarm8: void,
    looping_alarm9: void,
    looping_alarm10: void,
    looping_call: void,
    looping_call2: void,
    looping_call3: void,
    looping_call4: void,
    looping_call5: void,
    looping_call6: void,
    looping_call7: void,
    looping_call8: void,
    looping_call9: void,
    looping_call10: void,

    pub fn custom(uri: []const u8) @This() {
        return .{ .custom_uri = uri };
    }

    pub fn source(self: @This()) []const u8 {
        return switch (self) {
            .default => "ms-winsoundevent:Notification.Default",
            .im => "ms-winsoundevent:Notification.IM",
            .mail => "ms-winsoundevent:Notification.Mail",
            .reminder => "ms-winsoundevent:Notification.Reminder",
            .sms => "ms-winsoundevent:Notification.SMS",
            .looping_alarm => "ms-winsoundevent:Notification.Looping.Alarm",
            .looping_alarm2 => "ms-winsoundevent:Notification.Looping.Alarm2",
            .looping_alarm3 => "ms-winsoundevent:Notification.Looping.Alarm3",
            .looping_alarm4 => "ms-winsoundevent:Notification.Looping.Alarm4",
            .looping_alarm5 => "ms-winsoundevent:Notification.Looping.Alarm5",
            .looping_alarm6 => "ms-winsoundevent:Notification.Looping.Alarm6",
            .looping_alarm7 => "ms-winsoundevent:Notification.Looping.Alarm7",
            .looping_alarm8 => "ms-winsoundevent:Notification.Looping.Alarm8",
            .looping_alarm9 => "ms-winsoundevent:Notification.Looping.Alarm9",
            .looping_alarm10 => "ms-winsoundevent:Notification.Looping.Alarm10",
            .looping_call => "ms-winsoundevent:Notification.Looping.Call",
            .looping_call2 => "ms-winsoundevent:Notification.Looping.Call2",
            .looping_call3 => "ms-winsoundevent:Notification.Looping.Call3",
            .looping_call4 => "ms-winsoundevent:Notification.Looping.Call4",
            .looping_call5 => "ms-winsoundevent:Notification.Looping.Call5",
            .looping_call6 => "ms-winsoundevent:Notification.Looping.Call6",
            .looping_call7 => "ms-winsoundevent:Notification.Looping.Call7",
            .looping_call8 => "ms-winsoundevent:Notification.Looping.Call8",
            .looping_call9 => "ms-winsoundevent:Notification.Looping.Call9",
            .looping_call10 => "ms-winsoundevent:Notification.Looping.Call10",
            else => ""
        };
    }
};

pub const Config = struct { title: []const u8, body: ?[]const u8 = null, logo: ?struct {
    src: []const u8,
    alt: []const u8,
    crop: bool = false,
} = null, hero: ?struct {
    src: []const u8,
    alt: []const u8,
} = null, progress: ?struct {
    value: Progress,
    status: []const u8,
    title: ?[]const u8 = null,
    override: ?[]const u8 = null,
} = null, actions: ?[]const Action = null, audio: ?struct {
    sound: Audio,
    loop: ?bool = null,
} };

pub const Update = struct {
    title: ?[]const u8 = null,
    body: ?[]const u8 = null,
    progress: ?struct {
        value: ?Progress = null,
        status: ?[]const u8 = null,
        title: ?[]const u8 = null,
        override: ?[]const u8 = null,
    } = null,
};

pub const Notification = struct {
    config: Config,
    tag: []const u8,
    app_id: []const u8,

    pub fn send(alloc: std.mem.Allocator, app_id: ?[]const u8, tag: []const u8, config: Config) !@This() {
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

        try xml.actions(.open);
        if (config.actions) |actions| {
            for (actions) |action| {
                try xml.action(action);
            }
        }
        try xml.actions(.close);

        if (config.audio) |audio| {
            try xml.audio(audio.sound, audio.loop);
        }

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

        if (config.audio) |audio| {
            if (audio.sound == .custom_uri) {
                var media_player = try script.media_player();
                try media_player.createFromUri(audio.sound.custom_uri);
                try media_player.play();
            }
        }

        try script.endCommand();

        std.debug.print("{s}\n", .{script.buffer.items});

        try script.execute();

        return .{ .tag = tag, .app_id = app_id orelse "{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\\WindowsPowerShell\\v1.0\\powershell.exe", .config = config };
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
