const std = @import("std");
const win32 = @import("win32");

pub const S_OK: u32 = 0;
pub const CO_E_NOTINITIALIZED: u32 = 0x800401F0;
pub const E_ACCESSDENIED: u32 = 0x80070005;
pub const E_OUTOFMEMORY: u32 = 0x8007000E;
pub const REGDB_E_CLASSNOTREG: u32 = 0x80040154;
pub const CLSCTX_ALL = win32.system.com.CLSCTX_ALL;
pub const IID_IInspectable = win32.system.win_rt.IID_IInspectable;
pub const IID_IUnknown = win32.system.com.IID_IUnknown;
pub const IID_IAgileObject = win32.system.com.IID_IAgileObject;
pub const IID_IMarshal = win32.system.com.marshal.IID_IMarshal;

pub const IInspectable = win32.system.win_rt.IInspectable;
pub const IUnknown = win32.system.com.IUnknown;
pub const HRESULT = win32.foundation.HRESULT;
pub const HSTRING = win32.system.win_rt.HSTRING;
pub const Guid = win32.zig.Guid;
pub const TrustLevel = win32.system.win_rt.TrustLevel;

const WindowsCreateString = win32.system.win_rt.WindowsCreateString;
const WindowsDeleteString = win32.system.win_rt.WindowsDeleteString;
const CoCreateInstance = win32.system.com.CoCreateInstance;
const CoIncrementMTAUsage = win32.system.com.CoIncrementMTAUsage;
pub const CoInitializeEx = win32.system.com.CoInitializeEx;
const CoTaskMemFree = win32.system.com.CoTaskMemFree;
pub const CoUninitialize = win32.system.com.CoUninitialize;
const RoGetActivationFactory = win32.system.win_rt.RoGetActivationFactory;
const RoInitialize = win32.system.win_rt.RoInitialize;
const RoActivateInstance = win32.system.win_rt.RoActivateInstance;

/// Compute the GUID for a WinRT parameterized type from its canonical signature
/// using the WinRT "pinterface" namespace and RFC-4122 UUIDv5 (SHA-1).
///
/// # Example
/// + `pinterface({<PIID-of-open-generic>}; <arg1-signature>; <arg2-signature>; ...)`
///   + `rc(Namespace.Type;{<IID-of-default-interface>})` is the signature for a runtime class type argument
///   + `iinspectable` is the signature token for IInspectable
pub fn guidFromWinRTSignature(signature: []const u8) Guid {
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

pub const Error = error{
    /// No interface found for the given action, or the given class does not implement IInspectable
    NoInterface,
    /// The thread has not been initialized in the Windows Runtime by calling RoInitialize
    NotInitialized,
    /// The TrustLevel for the class requires a full-trust process
    AccessDenied,
    OutOfMemory,
};

pub const Color = extern struct { A: u8, R: u8, G: u8, B: u8 };

pub const HandPreference = enum(i32) {
    LeftHanded = 0,
    RightHanded = 1,
};

pub const UIElementType = enum(i32) {
    ActiveCaption = 0,
    Background = 1,
    ButtonFace = 2,
    ButtonText = 3,
    CaptionText = 4,
    GrayText = 5,
    Highlight = 6,
    HighlightText = 7,
    Hotlight = 8,
    InactiveCaption = 9,
    InactiveCaptionText = 10,
    Window = 11,
    WindowText = 12,
    AccentColor = 1000,
    TextHigh = 1001,
    TextMedium = 1002,
    TextLow = 1003,
    TextContrastWithHigh = 1004,
    NonTextHigh = 1005,
    NonTextMediumHigh = 1006,
    NonTextMedium = 1007,
    NonTextMediumLow = 1008,
    NonTextLow = 1009,
    PageBackground = 1010,
    PopupBackground = 1011,
    OverlayOutsidePopup = 1012,
};

pub const UIColorType = enum(i32) {
    Background = 0,
    Foreground = 1,
    AccentDark3 = 2,
    AccentDark2 = 3,
    AccentDark1 = 4,
    Accent = 5,
    AccentLight1 = 6,
    AccentLight2 = 7,
    AccentLight3 = 8,
    Complement = 9,
};

pub const IUISettings = extern struct {
    vtable: *const VTable,

    pub fn release(self: *const @This()) u32 {
        return self.vtable.Release(@ptrCast(self));
    }

    pub fn query_interface(self: *const @This(), riid: *const Guid, object: **anyopaque) i32 {
        return self.vtable.QueryInterface(@ptrCast(self), riid, object);
    }

    pub const GUID: []const u8 = "85361600-1c63-4627-bcb1-3a89e0bc9c55";
    pub const IID: Guid = Guid.initString(GUID);
    pub const VTable = extern struct {
        QueryInterface: *const fn (self: *const anyopaque, riid: *const Guid, ppvObject: **anyopaque) callconv(.C) HRESULT,
        AddRef: *const fn (self: *const anyopaque) callconv(.C) u32,
        Release: *const fn (self: *const anyopaque) callconv(.C) u32,

        GetIids: *const fn (self: *const anyopaque, iidCount: ?*u32, iids: [*]?*Guid) callconv(.C) HRESULT,
        GetRuntimeClassName: *const fn (self: *const anyopaque, className: ?*?HSTRING) callconv(.C) HRESULT,
        GetTrustLevel: *const fn (self: *const anyopaque, trustLevel: ?*TrustLevel) callconv(.C) HRESULT,

        HandPreference: *const fn (*const anyopaque, *HandPreference) callconv(.C) HRESULT,
        CursorSize: *const fn (*const anyopaque, *win32.foundation.SIZE) callconv(.C) HRESULT,
        ScrollBarSize: *const fn (*const anyopaque, *win32.foundation.SIZE) callconv(.C) HRESULT,
        ScrollBarArrowSize: *const fn (*const anyopaque, *win32.foundation.SIZE) callconv(.C) HRESULT,
        ScrollBarThumbBoxSize: *const fn (*const anyopaque, *win32.foundation.SIZE) callconv(.C) HRESULT,
        MessageDuration: *const fn (*const anyopaque, *u32) callconv(.C) HRESULT,
        AnimationsEnabled: *const fn (*const anyopaque, *bool) callconv(.C) HRESULT,
        CaretBrowsingEnabled: *const fn (*const anyopaque, *bool) callconv(.C) HRESULT,
        CaretBlinkRate: *const fn (*const anyopaque, *u32) callconv(.C) HRESULT,
        CaretWidth: *const fn (*const anyopaque, *u32) callconv(.C) HRESULT,
        DoubleClickTime: *const fn (*const anyopaque, *u32) callconv(.C) HRESULT,
        MouseHoverTime: *const fn (*const anyopaque, *u32) callconv(.C) HRESULT,
        UIElementColor: *const fn (*const anyopaque, UIElementType, *Color) callconv(.C) HRESULT,
    };
};

pub const IUISettings2 = extern struct {
    vtable: *const VTable,

    pub var TYPE_NAME: [37:0]u16 = [_:0]u16{ 'W', 'i', 'n', 'd', 'o', 'w', 's', '.', 'U', 'I', '.', 'V', 'i', 'e', 'w', 'M', 'a', 'n', 'a', 'g', 'e', 'm', 'e', 'n', 't', '.', 'U', 'I', 'S', 'e', 't', 't', 'i', 'n', 'g', 's', 0 };
    pub const RUNTIME_NAME: [:0]const u16 = TYPE_NAME[0..];
    pub const IID: Guid = Guid.initString("bad82401-2721-44f9-bb91-2bb228be442f");
    pub const VTable = extern struct {
        QueryInterface: *const fn (self: *const anyopaque, riid: *const Guid, ppvObject: **anyopaque) callconv(.C) HRESULT,
        AddRef: *const fn (self: *const anyopaque) callconv(.C) u32,
        Release: *const fn (self: *const anyopaque) callconv(.C) u32,

        GetIids: *const fn (self: *const anyopaque, iidCount: ?*u32, iids: [*]?*Guid) callconv(.C) HRESULT,
        GetRuntimeClassName: *const fn (self: *const anyopaque, className: ?*?HSTRING) callconv(.C) HRESULT,
        GetTrustLevel: *const fn (self: *const anyopaque, trustLevel: ?*TrustLevel) callconv(.C) HRESULT,

        TextScaleFactor: *const fn (*const anyopaque, *f64) callconv(.C) HRESULT,
        TextScaleFactorChanged: *const fn (*const anyopaque, *IInspectable, *i64) callconv(.C) HRESULT,
        RemoveTextScaleFactorChanged: *const fn (*const anyopaque, i64) callconv(.C) HRESULT,
    };
};

pub const IUISettings3 = extern struct {
    vtable: *const VTable,

    pub fn getColorValue(self: *const @This(), color_type: UIColorType) !Color {
        var result: Color = undefined;
        if (self.vtable.GetColorValue(@ptrCast(self), color_type, &result) < 0) {
            return error.GetColorFailure;
        }
        return result;
    }

    pub fn colorValuesChanged(self: *const @This(), handler: *TypedEventHandler(UISettings, IInspectable)) !i64 {
        var result: i64 = 0;
        const code = self.vtable.ColorValuesChanged(@ptrCast(self), @ptrCast(handler), &result);
        if (code < 0) {
            std.debug.print("0x{X}\n", .{@as(u32, @bitCast(code))});
            return error.BindHookFailure;
        }
        return result;
    }

    pub fn removeColorValuesChanged(self: *const @This(), id: i64) !void {
        if (self.vtable.RemoveColorValuesChanged(@ptrCast(self), id) < 0) {
            return error.UnbindHookFailure;
        }
    }

    pub var TYPE_NAME: [37:0]u16 = [_:0]u16{ 'W', 'i', 'n', 'd', 'o', 'w', 's', '.', 'U', 'I', '.', 'V', 'i', 'e', 'w', 'M', 'a', 'n', 'a', 'g', 'e', 'm', 'e', 'n', 't', '.', 'U', 'I', 'S', 'e', 't', 't', 'i', 'n', 'g', 's', 0 };
    pub const RUNTIME_NAME: [:0]const u16 = TYPE_NAME[0..];
    pub const IID: Guid = Guid.initString("03021be4-5254-4781-8194-5168f7d06d7b");
    pub const VTable = extern struct {
        QueryInterface: *const fn (self: *const anyopaque, riid: *const Guid, ppvObject: **anyopaque) callconv(.C) HRESULT,
        AddRef: *const fn (self: *const anyopaque) callconv(.C) u32,
        Release: *const fn (self: *const anyopaque) callconv(.C) u32,

        GetIids: *const fn (self: *const anyopaque, iidCount: ?*u32, iids: [*]?*Guid) callconv(.C) HRESULT,
        GetRuntimeClassName: *const fn (self: *const anyopaque, className: ?*?HSTRING) callconv(.C) HRESULT,
        GetTrustLevel: *const fn (self: *const anyopaque, trustLevel: ?*TrustLevel) callconv(.C) HRESULT,

        GetColorValue: *const fn (*const anyopaque, UIColorType, *Color) callconv(.C) HRESULT,
        ColorValuesChanged: *const fn (*const anyopaque, *ITypedEventHandler, *i64) callconv(.C) HRESULT,
        RemoveColorValuesChanged: *const fn (*const anyopaque, i64) callconv(.C) HRESULT,
    };
};

pub const IUISettings4 = extern struct {
    vtable: *const VTable,

    pub var TYPE_NAME: [37:0]u16 = [_:0]u16{ 'W', 'i', 'n', 'd', 'o', 'w', 's', '.', 'U', 'I', '.', 'V', 'i', 'e', 'w', 'M', 'a', 'n', 'a', 'g', 'e', 'm', 'e', 'n', 't', '.', 'U', 'I', 'S', 'e', 't', 't', 'i', 'n', 'g', 's', 0 };
    pub const RUNTIME_NAME: [:0]const u16 = TYPE_NAME[0..];
    pub const IID: Guid = Guid.initString("52bb3002-919b-4d6b-9b78-8dd66ff4b93b");
    pub const VTable = extern struct {
        QueryInterface: *const fn (self: *const anyopaque, riid: *const Guid, ppvObject: **anyopaque) callconv(.C) HRESULT,
        AddRef: *const fn (self: *const anyopaque) callconv(.C) u32,
        Release: *const fn (self: *const anyopaque) callconv(.C) u32,

        GetIids: *const fn (self: *const anyopaque, iidCount: ?*u32, iids: [*]?*Guid) callconv(.C) HRESULT,
        GetRuntimeClassName: *const fn (self: *const anyopaque, className: ?*?HSTRING) callconv(.C) HRESULT,
        GetTrustLevel: *const fn (self: *const anyopaque, trustLevel: ?*TrustLevel) callconv(.C) HRESULT,

        AdvancedEffectsEnabled: *const fn (*const anyopaque, *bool) callconv(.C) HRESULT,
        AdvancedEffectsEnabledChanged: *const fn (*const anyopaque, *IInspectable, *i64) callconv(.C) HRESULT,
        RemoveAdvancedEffectsEnabledChanged: *const fn (*const anyopaque, i64) callconv(.C) HRESULT,
    };
};

pub const IUISettings5 = extern struct {
    vtable: *const VTable,

    pub var TYPE_NAME: [37:0]u16 = [_:0]u16{ 'W', 'i', 'n', 'd', 'o', 'w', 's', '.', 'U', 'I', '.', 'V', 'i', 'e', 'w', 'M', 'a', 'n', 'a', 'g', 'e', 'm', 'e', 'n', 't', '.', 'U', 'I', 'S', 'e', 't', 't', 'i', 'n', 'g', 's', 0 };
    pub const RUNTIME_NAME: [:0]const u16 = TYPE_NAME[0..];
    pub const IID: Guid = Guid.initString("5349d588-0cb5-5f05-bd34-706b3231f0bd");
    pub const VTable = extern struct {
        QueryInterface: *const fn (self: *const anyopaque, riid: *const Guid, ppvObject: **anyopaque) callconv(.C) HRESULT,
        AddRef: *const fn (self: *const anyopaque) callconv(.C) u32,
        Release: *const fn (self: *const anyopaque) callconv(.C) u32,

        GetIids: *const fn (self: *const anyopaque, iidCount: ?*u32, iids: [*]?*Guid) callconv(.C) HRESULT,
        GetRuntimeClassName: *const fn (self: *const anyopaque, className: ?*?HSTRING) callconv(.C) HRESULT,
        GetTrustLevel: *const fn (self: *const anyopaque, trustLevel: ?*TrustLevel) callconv(.C) HRESULT,

        AutoHideScrollBars: *const fn (*const anyopaque, *bool) callconv(.C) HRESULT,
        AutoHideScrollBarsChanged: *const fn (*const anyopaque, *IInspectable, *i64) callconv(.C) HRESULT,
        RemoveAutoHideScrollBarsChanged: *const fn (*const anyopaque, i64) callconv(.C) HRESULT,
    };
};

pub const IUISettings6 = extern struct {
    vtable: *const VTable,

    pub var TYPE_NAME: [37:0]u16 = [_:0]u16{ 'W', 'i', 'n', 'd', 'o', 'w', 's', '.', 'U', 'I', '.', 'V', 'i', 'e', 'w', 'M', 'a', 'n', 'a', 'g', 'e', 'm', 'e', 'n', 't', '.', 'U', 'I', 'S', 'e', 't', 't', 'i', 'n', 'g', 's', 0 };
    pub const RUNTIME_NAME: [:0]const u16 = TYPE_NAME[0..];
    pub const IID: Guid = Guid.initString("aef19bd7_fe31_5a04_ada4_469aaec6dfa9");
    pub const VTable = extern struct {
        QueryInterface: *const fn (self: *const anyopaque, riid: *const Guid, ppvObject: **anyopaque) callconv(.C) HRESULT,
        AddRef: *const fn (self: *const anyopaque) callconv(.C) u32,
        Release: *const fn (self: *const anyopaque) callconv(.C) u32,

        GetIids: *const fn (self: *const anyopaque, iidCount: ?*u32, iids: [*]?*Guid) callconv(.C) HRESULT,
        GetRuntimeClassName: *const fn (self: *const anyopaque, className: ?*?HSTRING) callconv(.C) HRESULT,
        GetTrustLevel: *const fn (self: *const anyopaque, trustLevel: ?*TrustLevel) callconv(.C) HRESULT,

        AnimationsEnabledChanged: *const fn (*const anyopaque, *IInspectable, *i64) callconv(.C) HRESULT,
        RemoveAnimationsEnabledChanged: *const fn (*const anyopaque, i64) callconv(.C) HRESULT,
        MessageDurationChanged: *const fn (*const anyopaque, *IInspectable, *i64) callconv(.C) HRESULT,
        RemoveMessageDurationChanged: *const fn (*const anyopaque, i64) callconv(.C) HRESULT,
    };
};

pub const UISettings = extern struct {
    pub const TYPE_NAME: []const u8 = "Windows.UI.ViewManagement.UISettings";
    pub const SIGNATURE: []const u8 = std.fmt.comptimePrint("rc({s};{{{s}}})", .{ TYPE_NAME, IUISettings.GUID });

    pub const RUNTIME_NAME: [:0]const u16 = std.unicode.utf8ToUtf16LeStringLiteral(std.fmt.comptimePrint("{s}\x00", .{TYPE_NAME}));

    var Factory: FactoryCache = .{};

    vtable: *const IUISettings.VTable,

    pub fn init() anyerror!*@This() {
        const inner: *IUISettings = try @This().Factory.call(
            IGenericFactory,
            IUISettings,
            @This().RUNTIME_NAME,
        );
        return @ptrCast(@alignCast(inner));
    }

    pub fn deinit(self: *const @This()) u32 {
        return self.release();
    }

    pub fn release(self: *const @This()) u32 {
        const this: *const IUISettings = @ptrCast(@alignCast(self));
        return this.release();
    }

    pub fn getColorValue(self: *const @This(), color_type: UIColorType) !Color {
        const this: *const IUISettings = @ptrCast(@alignCast(self));

        var instance: *IUISettings3 = undefined;
        if (this.query_interface(&IUISettings3.IID, @ptrCast(&instance)) < 0) {
            return error.NoInterface;
        }

        return instance.getColorValue(color_type);
    }

    pub fn colorValuesChanged(self: *const @This(), handler: *TypedEventHandler(UISettings, IInspectable)) !i64 {
        const this: *const IUISettings = @ptrCast(@alignCast(self));

        var instance: *IUISettings3 = undefined;
        if (this.query_interface(&IUISettings3.IID, @ptrCast(&instance)) < 0) {
            return error.NoInterface;
        }

        return instance.colorValuesChanged(handler);
    }

    pub fn removeColorValuesChanged(self: *const @This(), id: i64) !void {
        const this: *const IUISettings = @ptrCast(@alignCast(self));

        var instance: *IUISettings3 = undefined;
        if (this.query_interface(&IUISettings3.IID, @ptrCast(&instance)) < 0) {
            return error.NoInterface;
        }

        try instance.removeColorValuesChanged(id);
    }
};

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
        cb: *const fn (sender: *I) callconv(.C) void,

        pub fn init(callback: *const fn (sender: *I) callconv(.C) void) !@This() {
            std.debug.print("{s}\n", .{SIGNATURE});
            return .{
                .vtable = &VTABLE,
                .refs = std.atomic.Value(u32).init(1),
                .cb = callback,
            };
        }

        fn query_interface(self: *anyopaque, riid: *const Guid, out: *?*anyopaque) callconv(.C) HRESULT {
            const me: *@This() = @ptrCast(@alignCast(self));
            // Support IUnknown and (optionally) the exact delegate IID.
            if (std.mem.eql(u8, &riid.Bytes, &wiredGuid(&IID).Bytes) or
                std.mem.eql(u8, &riid.Bytes, &wiredGuid(IID_IUnknown).Bytes) or
                std.mem.eql(u8, &riid.Bytes, &wiredGuid(IID_IAgileObject).Bytes))
            {
                out.* = @as(?*anyopaque, @ptrCast(me));
                _ = add_ref(self);
                return 0; // S_OK
            }
            out.* = null;
            return -2147467262; // E_NOINTERFACE
        }

        fn add_ref(self: *anyopaque) callconv(.C) u32 {
            const me: *@This() = @ptrCast(@alignCast(self));
            return me.refs.fetchAdd(1, .monotonic) + 1;
        }

        fn release(self: *anyopaque) callconv(.C) u32 {
            const me: *@This() = @ptrCast(@alignCast(self));
            const left = me.refs.fetchSub(1, .acq_rel) - 1;
            if (left == 0) {
                // std.heap.c_allocator.destroy(me);
            }
            return left;
        }

        // Invoke(sender, args) — QI sender to IUISettings3 and call user cb
        fn invoke(self: *ITypedEventHandler, sender: *anyopaque, _: *anyopaque) callconv(.C) HRESULT {
            const this: *@This() = @ptrCast(@alignCast(self));
            std.debug.print("[COLOR CHANGE]\n", .{});
            this.cb(@ptrCast(@alignCast(sender)));
            return S_OK; // S_OK regardless; you usually don’t fail event callbacks
        }
    };
}

pub const IGenericFactory = extern struct {
    pub const VTable = extern struct { base: IInspectable.VTable, ActivateInstance: *const fn (*IGenericFactory, **anyopaque) callconv(.C) HRESULT };

    vtable: *const VTable,

    pub const IID: Guid = Guid.initString("00000035-0000-0000-c000-000000000046");

    pub fn ActivateInstance(self: *IGenericFactory, R: type) Error!*R {
        var inspectable: *IInspectable = undefined;
        const code = @as(u32, @bitCast(self.vtable.ActivateInstance(self, @ptrCast(@alignCast(&inspectable)))));
        if (code < S_OK) return error.NoInterface;

        var result: *R = undefined;
        if (inspectable.vtable.base.QueryInterface(@ptrCast(inspectable), &R.IID, @ptrCast(&result)) < S_OK) {
            return error.NoInterface;
        }

        return result;
    }
};

// ALTERNATE METHOD TO INITIALIZING CLASS
// var name: ?HSTRING = undefined;
// if (@as(u32, @bitCast(WindowsCreateString(@This().RUNTIME_NAME.ptr, @intCast(@This().RUNTIME_NAME.len-1), &name))) != S_OK) {
//     return error.OutOfMemory;
// }
// defer _ = WindowsDeleteString(name);
//
// var inspectable: *IInspectable = undefined;
// var activation_result = RoActivateInstance(name, &inspectable);
//
// if (@as(u32, @bitCast(activation_result)) == CO_E_NOTINITIALIZED) {
//     var cookie: isize = undefined;
//     _ = CoIncrementMTAUsage(&cookie);
//
//     activation_result = RoActivateInstance(name, &inspectable);
// }
//
// if (activation_result < 0) return error.ActivationFailure;
//
// var instance: *IUISettings = undefined;
// if (inspectable.vtable.base.QueryInterface(@ptrCast(@alignCast(inspectable)), &IUISettings.IID, @ptrCast(&instance)) < 0) {
//     return error.NoInterface;
// }
//
// return .{ .vtable = instance };

pub const FactoryCache = struct {
    shared: std.atomic.Value(?*anyopaque) = .init(null),

    pub fn call(self: *@This(), I: type, R: type, runtime_name: [:0]const u16) !*R {
        while (true) {
            // Attempt to load a previously cached factory pointer.
            if (self.shared.load(.acquire)) |ptr| {
                // If a pointer is found, the cache is primed and we're good to go.
                return try I.ActivateInstance(@ptrCast(@alignCast(ptr)), R);
            }

            // Otherwise, we load the factory the usual way.
            const factory = try load_factory(I, runtime_name);

            // If the factory is agile, we can safely cache it.
            const unknown: *IUnknown = @ptrCast(@alignCast(factory));

            var temp: *anyopaque = undefined;
            if (@as(u32, @bitCast(unknown.QueryInterface(IID_IAgileObject, &temp))) == S_OK) {
                _ = self.shared.cmpxchgStrong(null, factory, .acq_rel, .acquire);
            } else {
                // Otherwise, for non-agile factories we simply use the factory
                // and discard after use as it is not safe to cache.
                return try I.ActivateInstance(@ptrCast(@alignCast(factory)), R);
            }
        }
    }
};

fn load_factory(I: type, runtime_name: [:0]const u16) Error!*anyopaque {
    const interface_iid: *const Guid = &I.IID;

    var factory: *anyopaque = undefined;

    var name: ?HSTRING = undefined;
    if (@as(u32, @bitCast(WindowsCreateString(runtime_name.ptr, @intCast(runtime_name.len - 1), &name))) != S_OK) {
        return error.OutOfMemory;
    }
    defer _ = WindowsDeleteString(name);

    const code = code_block: {
        var result: u32 = @bitCast(RoGetActivationFactory(
            name,
            interface_iid,
            &factory,
        ));

        // If RoGetActivationFactory fails because combase hasn't been loaded yet then load combase
        // automatically so that it "just works" for apartment-agnostic code.
        if (result == CO_E_NOTINITIALIZED) {
            var cookie: isize = undefined;
            // Attempt initialize
            _ = CoIncrementMTAUsage(&cookie);
            // _ = RoInitialize(.MULTITHREADED);

            // Now try a second time to get the activation factory via the OS.
            result = @bitCast(RoGetActivationFactory(
                name,
                interface_iid,
                &factory,
            ));
        }

        break :code_block result;
    };

    // If this succeeded then return the resulting factory interface.
    if (code == S_OK) {
        return factory;
    }

    // If not, first capture the error information from the failure above so that we
    // can ultimately return this error information if all else fails.
    // let original: crate::Error = code.into();

    // Reg-free activation should only be attempted if the class is not registered.
    // It should not be attempted if the class is registered but fails to activate.
    if (code == REGDB_E_CLASSNOTREG) {
        // Now attempt to find the factory's implementation heuristically.
        if (try searchPath(runtime_name, &name)) |i| {
            return i;
        }
    }

    return error.NoInterface;
}

const suffix: []const u16 = std.unicode.utf8ToUtf16LeStringLiteral(".dll");

// Remove the suffix until a match is found appending `.dll\0` at the end
///
/// For example, if the class name is
/// "A.B.TypeName" then the attempted load order will be:
///   1. A.B.dll
///   2. A.dll
fn searchPath(runtime_path: [:0]const u16, name: *?HSTRING) Error!?*anyopaque {
    var path: []const u16 = runtime_path[0..];

    while (std.mem.lastIndexOf(u16, path, '.')) |pos| {
        path = path[0..pos];

        var library: [:0]u16 = std.heap.smp_allocator.allocSentinel(u16, path.len + suffix.len, 0) catch return error.OutOfMemory;
        defer std.heap.smp_allocator.free(library);

        @memcpy(library[0..path.len], path);
        @memcpy(library[path.len..], suffix);

        if (getActivationFactory(library.ptr, name)) |r| {
            return r;
        }
    }
    return null;
}

fn getActivationFactory(
    library: [*:0]const u16,
    name: *?HSTRING,
) ?*anyopaque {
    const function = delay_load(DllGetActivationFactory, library, DllGetActivationFactoryName.ptr) orelse return null;
    var abi: *anyopaque = undefined;
    const result = function(@ptrCast(@alignCast(name)), &abi);
    if (result == 0) {
        return @ptrCast(@alignCast(abi));
    }
    return null;
}

fn delay_load(T: type, library: [*:0]const u16, function: [*:0]const u8) ?T {
    const lib = win32.system.library_loader.LoadLibraryExW(
        library,
        null,
        win32.system.library_loader.LOAD_LIBRARY_SEARCH_DEFAULT_DIRS,
    );

    if (lib == null) return null;

    const address = win32.system.library_loader.GetProcAddress(lib, function);

    if (address) |a| {
        return @ptrCast(@alignCast(a));
    }

    _ = win32.system.library_loader.FreeLibrary(lib);
    return null;
}

const DllGetActivationFactory = *const fn (name: *anyopaque, factory: **anyopaque) HRESULT;
const DllGetActivationFactoryName: [:0]const u8 = "DllGetActivationFactory";
