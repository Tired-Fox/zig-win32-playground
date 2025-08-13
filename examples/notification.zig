const std = @import("std");
const process = std.process;

const Notification = struct {
    config: Config,
    tag: []const u8,
    app_id: []const u8,

    pub fn update(self: *const @This(), alloc: std.mem.Allocator, config: Update) !void {
        var snippet = std.ArrayList(u8).init(alloc);
        defer snippet.deinit();

        try snippet.appendSlice(
            \\Invoke-Command -ScriptBlock {
            \\    $Dictionary = [System.Collections.Generic.Dictionary[String, String]]::New()
            \\
        );

        // TODO: Add dictionary values
        var line: []const u8 = undefined;

        if (config.title) |title| {
            line = try std.fmt.allocPrint(alloc, "    $Dictionary.Add('notificationTitle', '{s}')\n", .{ title });
            try snippet.appendSlice(line);
            alloc.free(line);
        }

        if (config.body) |body| {
            if (self.config.body == null) return error.NotificationBodyNotConfigured;
            line = try std.fmt.allocPrint(alloc, "    $Dictionary.Add('notificationBody', '{s}')\n", .{ body });
            try snippet.appendSlice(line);
            alloc.free(line);
        }

        if (config.progress) |progress| {
            if (self.config.progress == null) return error.NotificationProgressNotConfigured;
            if (progress.title) |title| {
                if (self.config.progress.?.title == null) return error.NotificationProgressTitleNotConfigured;
                line = try std.fmt.allocPrint(alloc, "    $Dictionary.Add('progressTitle', '{s}')\n", .{ title });
                try snippet.appendSlice(line);
                alloc.free(line);
            }

            if (progress.value) |value| {
                switch (value) {
                    .intermediate => try snippet.appendSlice("    $Dictionary.Add('progressValue', 'intermediate')\n"),
                    .value => |v| {
                        line = try std.fmt.allocPrint(alloc, "    $Dictionary.Add('progressValue', '{d}')\n", .{ v });
                        try snippet.appendSlice(line);
                        alloc.free(line);
                    }
                }
            }

            if (progress.status) |status| {
                line = try std.fmt.allocPrint(alloc, "    $Dictionary.Add('progressStatus', '{s}')\n", .{ status });
                try snippet.appendSlice(line);
                alloc.free(line);
            }

            if (progress.override) |override| {
                if (self.config.progress.?.override == null) return error.NotificationProgressValueStringNotConfigured;
                line = try std.fmt.allocPrint(alloc, "    $Dictionary.Add('progressValueString', '{s}')\n", .{ override });
                try snippet.appendSlice(line);
                alloc.free(line);
            }
        }

        try snippet.appendSlice(
            \\    $NotificationData = [Windows.UI.Notifications.NotificationData]::New($Dictionary)
            \\    $NotificationData.SequenceNumber = 2
            \\
        );

        line = try std.fmt.allocPrint(alloc, "    $AppId = '{s}'\n", .{ self.app_id });
        try snippet.appendSlice(line);
        alloc.free(line);

        try snippet.appendSlice(
            \\    $Notifier = [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]::CreateToastNotifier($AppId)
            \\
        );

        line = try std.fmt.allocPrint(alloc, "    $Notifier.Update($NotificationData, '{s}')\n}}", .{ self.tag });
        try snippet.appendSlice(line);
        alloc.free(line);

        const result = try process.Child.run(.{ .allocator = alloc, .argv = &.{ "powershell", "-c", snippet.items } });
        alloc.free(result.stdout);
        alloc.free(result.stderr);
    }
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

const Config = struct {
    title: []const u8,
    body: ?[]const u8 = null,
    progress: ?struct {
        value: Progress,
        status: []const u8,
        title: ?[]const u8 = null,
        override: ?[]const u8 = null,
    } = null,
};

const Progress = union(enum) {
    intermediate: void,
    value: f32,
    fn progress(v: f32) @This() {
        return .{ .value = v };
    }
};

fn send(alloc: std.mem.Allocator, app_id: ?[]const u8, tag: []const u8, config: Config) !Notification {
    var snippet = std.ArrayList(u8).init(alloc);
    defer snippet.deinit();
    var line: []const u8 = undefined;

    try snippet.appendSlice(
        \\Invoke-Command -ScriptBlock {
        \\    $xml = '
        \\        <toast>
        \\            <visual>
        \\                <binding template="ToastGeneric">
        \\                    <text id="1" hint-style="title">{notificationTitle}</text>
        \\
    );

    if (config.body != null) {
        try snippet.appendSlice(
            \\                  <text id="2">{notificationBody}</text>
            \\
        );
    }

    // TODO: Add visual content
    if (config.progress) |progress| {
        try snippet.appendSlice(
            \\                <progress
            \\                    value="{progressValue}"
            \\                    status="{progressStatus}"/>
            \\
        );

        if (progress.title != null) {
            try snippet.appendSlice(
                \\                    title="{progressTitle}"
                \\
            );
        }
        if (progress.override != null) {
            try snippet.appendSlice(
                \\                    valueStringOverride="{progressValueString}"
                \\
            );
        }
    }

    try snippet.appendSlice(
        \\                </binding>
        \\            </visual>
        \\        </toast>
        \\    ';
        \\
        \\    $XmlDocument = [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime]::New()
        \\    $XmlDocument.loadXml($xml)
        \\    $AppId = '
    );
    try snippet.appendSlice(if (app_id) |id| id else "{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\\WindowsPowerShell\\v1.0\\powershell.exe");
    try snippet.appendSlice("'\n");
    try snippet.appendSlice(
        \\    $ToastNotification = [Windows.UI.Notifications.ToastNotification, Windows.UI.Notifications, ContentType = WindowsRuntime]::New($XmlDocument)
        \\    $ToastNotification.Tag = '
    );
    try snippet.appendSlice(tag);
    try snippet.appendSlice("'\n");
    try snippet.appendSlice(
        \\    $Dictionary = [System.Collections.Generic.Dictionary[String, String]]::New()
        \\
    );

    line = try std.fmt.allocPrint(alloc, "    $Dictionary.Add('notificationTitle', '{s}')\n", .{ config.title });
    try snippet.appendSlice(line);
    alloc.free(line);

    if (config.body) |body| {
        line = try std.fmt.allocPrint(alloc, "    $Dictionary.Add('notificationBody', '{s}')\n", .{ body });
        try snippet.appendSlice(line);
        alloc.free(line);
    }

    if (config.progress) |progress| {
        if (progress.title) |title| {
            line = try std.fmt.allocPrint(alloc, "    $Dictionary.Add('progressTitle', '{s}')\n", .{title});
            try snippet.appendSlice(line);
            alloc.free(line);
        }

        switch (progress.value) {
            .intermediate => try snippet.appendSlice("    $Dictionary.Add('progressValue', 'intermediate')\n"),
            .value => |v| {
                line = try std.fmt.allocPrint(alloc, "    $Dictionary.Add('progressValue', '{d}')\n", .{v});
                try snippet.appendSlice(line);
                alloc.free(line);
            }
        }

        if (progress.override) |override| {
            line = try std.fmt.allocPrint(alloc, "    $Dictionary.Add('progressValueString', '{s}')\n", .{override});
            try snippet.appendSlice(line);
            alloc.free(line);
        }

        line = try std.fmt.allocPrint(alloc, "    $Dictionary.Add('progressStatus', '{s}')\n", .{progress.status});
        try snippet.appendSlice(line);
        alloc.free(line);
    }

    try snippet.appendSlice(
        \\    $ToastNotification.Data = [Windows.UI.Notifications.NotificationData]::New($Dictionary)
        \\    $ToastNotification.Data.SequenceNumber = 1
        \\
        \\    $Notifier = [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]::CreateToastNotifier($AppId)
        \\    $Notifier.Show($ToastNotification);
        \\}
    );

    const result = try process.Child.run(.{ .allocator = alloc, .argv = &.{ "powershell", "-c", snippet.items } });
    alloc.free(result.stdout);
    alloc.free(result.stderr);

    return .{
        .tag = tag,
        .app_id = app_id orelse "{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\\WindowsPowerShell\\v1.0\\powershell.exe",
        .config = config
    };
}

pub fn main() !void {
    const notification = try send(std.heap.smp_allocator, null, "zig-test-notif", .{
        .title="Updating Application",
        .progress = .{
            .value = .progress(0.0),
            .status = "Installing...",
            .override = "0/100"
        }
    });

    inline for (1..10) |i| {
        try notification.update(
            std.heap.smp_allocator,
            .{
                .progress = .{
                    .value = .progress(@as(f32, @floatFromInt(i)) * 0.1),
                    .override = std.fmt.comptimePrint("{d}/100", .{i * 10})
                }
            }
        );
        std.time.sleep(500 * std.time.ns_per_ms);
    }

    try notification.update(
        std.heap.smp_allocator,
        .{
            .title = "Latest version installed!",
            .progress = .{
                .value = .progress(1.0),
                .status = "Completed",
                .override = "100/100"
            }
        }
    );
}
