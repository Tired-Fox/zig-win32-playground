pub const std = @import("std");
pub const win32 = @import("win32");
pub const winrt = @import("../winrt.zig");

pub const Guid = win32.zig.Guid;
pub const HRESULT = win32.foundation.HRESULT;

pub const IID_IUnknown = win32.system.com.IID_IUnknown;
pub const IID_IAgileObject = win32.system.com.IID_IAgileObject;
pub const S_OK = winrt.S_OK;
pub const E_NOINTERFACE = winrt.E_NOINTERFACE;

/// Compute the GUID for a WinRT parameterized type from its canonical signature
/// using the WinRT "pinterface" namespace and RFC-4122 UUIDv5 (SHA-1).
///
/// # Example
/// + `pinterface({<PIID-of-open-generic>};<arg1-signature>;<arg2-signature>;...)`
///   + `rc(Namespace.Type;{<IID-of-default-interface>})` is the signature for a runtime class type argument
///   + `cinterface(IInspectable)` is the signature token for IInspectable
fn guidFromWinRTSignature(signature: []const u8) Guid {
    // WinRT "pinterface" namespace UUID in big-endian (RFC-4122 wire order):
    // 11F47AD5-7B73-42C0-ABAE-878B1E16ADEE
    const ns_be: [16]u8 = .{
        0x11, 0xF4, 0x7A, 0xD5, 0x7B, 0x73, 0x42, 0xC0,
        0xAB, 0xAE, 0x87, 0x8B, 0x1E, 0x16, 0xAD, 0xEE,
    };

    var hasher = std.crypto.hash.Sha1.init(.{});
    hasher.update(&ns_be);
    hasher.update(signature);

    var digest: [20]u8 = undefined;
    hasher.final(&digest);

    var bytes = digest[0..16].*; // first 16 bytes
    // RFC-4122 fixes:
    bytes[6] = (bytes[6] & 0x0F) | 0x50; // version = 5
    bytes[8] = (bytes[8] & 0x3F) | 0x80; // variant = RFC-4122

    return Guid{ .Bytes = bytes };
}

/// GUID values must be wire order when matching with GUID passed in from windows
///
/// This means the first 4 + 2 + 2 bytes are big endian and the rest are little endian.
/// + First 4 are reversed for the first value
/// + Next 2 bytes are reversed for the second value
/// + Next 2 bytes are reversed for the third value
/// + Remaining 8 bytes are kept as is for the fourth value
pub fn wiredGuid(iid: *const Guid) Guid {
    const bytes = iid.Bytes;
    return .{
        .Bytes = [16]u8{
            bytes[3],  bytes[2],  bytes[1],  bytes[0],
            bytes[5],  bytes[4],  bytes[7],  bytes[6],
            bytes[8],  bytes[9],  bytes[10], bytes[11],
            bytes[12], bytes[13], bytes[14], bytes[15],
        },
    };
}

/// helper to format a GUID as dashed lowercase hex
///
/// Buffer must be 36+ bytes
pub fn guidToString(g: *const Guid, buf: []u8) std.fmt.BufPrintError![]u8 {
    const bytes = g.Bytes;
    return try std.fmt.bufPrint(
        buf,
        "{X:0>2}{X:0>2}{X:0>2}{X:0>2}-{X:0>2}{X:0>2}-{X:0>2}{X:0>2}-{X:0>2}{X:0>2}-{X:0>2}{X:0>2}{X:0>2}{X:0>2}{X:0>2}{X:0>2}",
        .{
            bytes[0],  bytes[1],  bytes[2],  bytes[3],
            bytes[4],  bytes[5],  bytes[6],  bytes[7],
            bytes[8],  bytes[9],  bytes[10], bytes[11],
            bytes[12], bytes[13], bytes[14], bytes[15],
        },
    );
}

// The type erased interface for a TypedEventHandler
//
// The first part of the memory layout is the same as `TypedEventHandler(I, R)`
// so it functions as expected when the pointers are cast between the two types
// when crossing the boundry between zig and windows.
pub const ITypedEventHandler = extern struct {
    // COM vtable layout
    vtable: *const VTable,

    pub const VTable = extern struct {
        QueryInterface: *const fn (
            self: *anyopaque,
            riid: *const Guid,
            ppvObject: *?*anyopaque,
        ) callconv(.C) HRESULT,
        AddRef: *const fn (
            self: *anyopaque,
        ) callconv(.C) u32,
        Release: *const fn (
            self: *anyopaque,
        ) callconv(.C) u32,

        // Invoke method for the delegate
        Invoke: *const fn (
            self: *ITypedEventHandler,
            sender: *anyopaque,
            args: *anyopaque,
        ) callconv(.C) HRESULT,
    };
};

/// Represents a method that handles general events
///
/// This method handles delegating the invoked callback for a
/// given typed event.
pub fn TypedEventHandler(I: type, R: type) type {
    const r_signature = if (@hasDecl(R, "SIGNATURE"))
        @field(R, "SIGNATURE")
    else blk: {
        const idx = std.mem.lastIndexOf(u8, @typeName(R), ".");
        break :blk std.fmt.comptimePrint("cinterface({s})", .{ if (idx) |i| @typeName(R)[i+|1..] else @typeName(R) });
    };

    const signature: []const u8 = std.fmt.comptimePrint("pinterface({{9de1c534-6ae1-11e0-84e1-18a905bcc53f}};{s};{s})", .{ I.SIGNATURE, r_signature });
    const guid = guidFromWinRTSignature(signature);

    return extern struct {
        const SIGNATURE = signature;
        const IID = guid;

        // pub const IID: Guid = Guid.initString("9de1c534-6ae1-11e0-84e1-18a905bcc53f");
        pub const VTABLE = ITypedEventHandler.VTable{
            .QueryInterface = query_interface,
            .AddRef = add_ref,
            .Release = release,
            .Invoke = invoke,
        };

        vtable: *const ITypedEventHandler.VTable,
        refs: std.atomic.Value(u32),
        cb: *const fn (sender: *I, context: ?*anyopaque) callconv(.C) void,
        context: ?*anyopaque = null,

        pub fn init(callback: *const fn (sender: *I, context: ?*anyopaque) callconv(.C) void) !@This() {
            return .{
                .vtable = &VTABLE,
                .refs = std.atomic.Value(u32).init(1),
                .cb = callback,
            };
        }

        pub fn initWithState(callback: *const fn (sender: *I, context: ?*anyopaque) callconv(.C) void, context: anytype) !@This() {
            return .{
                .vtable = &VTABLE,
                .refs = std.atomic.Value(u32).init(1),
                .cb = callback,
                .context = @ptrCast(context),
            };
        }

        fn query_interface(self: *anyopaque, riid: *const Guid, out: *?*anyopaque) callconv(.C) HRESULT {
            const me: *@This() = @ptrCast(@alignCast(self));
            // TODO: Handle IMarshal
            if (std.mem.eql(u8, &riid.Bytes, &wiredGuid(&IID).Bytes) or
                std.mem.eql(u8, &riid.Bytes, &wiredGuid(IID_IUnknown).Bytes) or
                std.mem.eql(u8, &riid.Bytes, &wiredGuid(IID_IAgileObject).Bytes))
            {
                out.* = @as(?*anyopaque, @ptrCast(me));
                _ = add_ref(self);
                return S_OK;
            }
            out.* = null;
            return @bitCast(E_NOINTERFACE);
        }

        fn add_ref(self: *anyopaque) callconv(.C) u32 {
            const me: *@This() = @ptrCast(@alignCast(self));
            return me.refs.fetchAdd(1, .monotonic) + 1;
        }

        fn release(self: *anyopaque) callconv(.C) u32 {
            const me: *@This() = @ptrCast(@alignCast(self));
            const left = me.refs.fetchSub(1, .acq_rel) - 1;
            return left;
        }

        // Invoke(sender, args) - Convert sender to `I` and pass it to the stored callback
        //
        // This will always return `S_OK` because event callbacks shouldn't fail
        fn invoke(self: *ITypedEventHandler, sender: *anyopaque, _: *anyopaque) callconv(.C) HRESULT {
            const this: *@This() = @ptrCast(@alignCast(self));
            // TODO: Allow user to store a pointer to some state in this delegate so it can be
            //       passed to the callback
            this.cb(@ptrCast(@alignCast(sender)), this.context);
            return S_OK;
        }
    };
}
