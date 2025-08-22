const std = @import("std");
const core = @import("core.zig");
const win32 = @import("win32");
const winrt = @import("../winrt.zig");

const Guid = win32.zig.Guid;
const HRESULT = win32.foundation.HRESULT;
const Signature = core.Signature;

const IID_IUnknown = win32.system.com.IID_IUnknown;
const IID_IAgileObject = win32.system.com.IID_IAgileObject;
const S_OK = winrt.S_OK;
const E_NOINTERFACE = winrt.E_NOINTERFACE;

pub const collections = @import("foundation/collections.zig");

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
    const signature: []const u8 = Signature.pinterface("9de1c534-6ae1-11e0-84e1-18a905bcc53f", &.{ I.Signature, Signature.cinterface(R) });
    const guid = Signature.guid(signature);

    return extern struct {
        const SIGNATURE = signature;
        const IID = guid;

        // pub const IID: Guid = Guid.initString("9de1c534-6ae1-11e0-84e1-18a905bcc53f");
        pub const VTABLE = ITypedEventHandler.VTable{
            .QueryInterface = queryInterface,
            .AddRef = addRef,
            .Release = release,
            .Invoke = invoke,
        };

        vtable: *const ITypedEventHandler.VTable,
        refs: std.atomic.Value(u32),
        cb: *const fn (context: ?*anyopaque, sender: *I, args: *R) callconv(.C) void,
        context: ?*anyopaque = null,

        pub fn init(callback: *const fn (context: ?*anyopaque, sender: *I, args: *R) callconv(.C) void) !@This() {
            return .{
                .vtable = &VTABLE,
                .refs = std.atomic.Value(u32).init(1),
                .cb = callback,
            };
        }

        pub fn initWithState(callback: *const fn (context: ?*anyopaque, sender: *I, args: *R) callconv(.C) void, context: anytype) !@This() {
            return .{
                .vtable = &VTABLE,
                .refs = std.atomic.Value(u32).init(1),
                .cb = callback,
                .context = @ptrCast(context),
            };
        }

        fn queryInterface(self: *anyopaque, riid: *const Guid, out: *?*anyopaque) callconv(.C) HRESULT {
            const me: *@This() = @ptrCast(@alignCast(self));
            // TODO: Handle IMarshal
            if (std.mem.eql(u8, &riid.Bytes, &wiredGuid(&IID).Bytes) or
                std.mem.eql(u8, &riid.Bytes, &wiredGuid(IID_IUnknown).Bytes) or
                std.mem.eql(u8, &riid.Bytes, &wiredGuid(IID_IAgileObject).Bytes))
            {
                out.* = @as(?*anyopaque, @ptrCast(me));
                _ = addRef(self);
                return S_OK;
            }
            out.* = null;
            return @bitCast(E_NOINTERFACE);
        }

        fn addRef(self: *anyopaque) callconv(.C) u32 {
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
        fn invoke(self: *ITypedEventHandler, sender: *anyopaque, args: *anyopaque) callconv(.C) HRESULT {
            const this: *@This() = @ptrCast(@alignCast(self));
            // TODO: Allow user to store a pointer to some state in this delegate so it can be
            //       passed to the callback
            this.cb(this.context, @ptrCast(@alignCast(sender)), @ptrCast(@alignCast(args)));
            return S_OK;
        }
    };
}
