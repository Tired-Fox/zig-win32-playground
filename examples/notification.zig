const std = @import("std");
const Notification = @import("utils").notification.Notification;

fn relative_file_uri(allocator: std.mem.Allocator, path: []const u8) ![]const u8 {
    const file_path = try std.fs.cwd().realpathAlloc(allocator, path);
    defer allocator.free(file_path);

    const uri = try std.fmt.allocPrint(allocator, "file:///{s}", .{ file_path });
    return uri;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.smp_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const hero_uri = try relative_file_uri(allocator, "examples\\images\\hero.png");
    const logo_uri = try relative_file_uri(allocator, "examples\\images\\logo.png");
    const button_appreciation = try relative_file_uri(allocator, "examples\\images\\button_appreciation.png");
    const button_read = try relative_file_uri(allocator, "examples\\images\\button_read.png");

    const notification = try Notification.send(std.heap.smp_allocator, null, "zig-test-notif", .{
        .title = "Zig Powershell Based Notifications",
        .body = "Some magic included to make powershell send a notification from zig",
        .hero = .{ .src = hero_uri, .alt = "Banner" },
        .logo = .{
            .src = logo_uri,
            .alt = "Logo",
            .crop = true,
        },
        .progress = .{
            .value = .progress(0.0),
            .status = "Downloading...",
        },
        .actions = &.{
            .Button(.{
                .arguments = "https://ziglang.org/",
                .activation_type = .protocol,
                .image_uri = button_appreciation,
                .hint_tool_tip = "Appreciation",
            }),
            .Button(.{
                .arguments = "https://ziglang.org/documentation/master/",
                .activation_type = .protocol,
                .image_uri = button_read,
                .hint_tool_tip = "Read",
            })
        },
        .audio = .{ .sound = .custom("https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3") }
    });

    inline for (1..10) |i| {
        try notification.update(std.heap.smp_allocator, .{
            .progress = .{
                .value = .progress(@as(f32, @floatFromInt(i)) * 0.1),
                .status = if (i > 5) "Installing..." else "Downloading...",
            },
        });
        std.time.sleep(500 * std.time.ns_per_ms);
    }

    try notification.update(std.heap.smp_allocator, .{
        .progress = .{
            .value = .progress(1.0),
            .status = "Completed",
        },
    });
}
