const std = @import("std");
const win32 = @import("win32");

pub const IInspectable = win32.system.win_rt.IInspectable;
pub const IID_IInspectable = win32.system.win_rt.IID_IInspectable;
pub const IUnknown = win32.system.com.IUnknown;
pub const IID_IUnknown = win32.system.com.IID_IUnknown;
pub const IID_IAgileObject = win32.system.com.IID_IAgileObject;
pub const HRESULT = win32.foundation.HRESULT;
pub const Guid = win32.zig.Guid;
pub const HSTRING = win32.system.win_rt.HSTRING;
pub const TrustLevel = win32.system.win_rt.TrustLevel;
const WindowsCreateString = win32.system.win_rt.WindowsCreateString;
const WindowsDeleteString = win32.system.win_rt.WindowsDeleteString;
const RoGetActivationFactory = win32.system.win_rt.RoGetActivationFactory;
const RoInitialize = win32.system.win_rt.RoInitialize;
const RoActivateInstance = win32.system.win_rt.RoActivateInstance;
const CoIncrementMTAUsage = win32.system.com.CoIncrementMTAUsage;

// https://learn.microsoft.com/en-us/windows/win32/api/rometadataresolution/nf-rometadataresolution-rogetmetadatafile
// https://learn.microsoft.com/en-us/windows/win32/api/rometadata/nf-rometadata-metadatagetdispenser
pub extern "api-ms-win-core-winrt-rometadataresolution-l1-1-0" fn RoGetMetaDataFile (
    name: HSTRING,
    dispenser: ?*IMetaDataDispenserEx,
    file_path: ?HSTRING,
    import: ?**IMetaDataImport2,
    type_def_token: ?*mdTypeDef,
) callconv(@import("std").os.windows.WINAPI) HRESULT;

pub const CoInitializeEx = win32.system.com.CoInitializeEx;
pub const CLSCTX_ALL = win32.system.com.CLSCTX_ALL;
pub const CoUninitialize = win32.system.com.CoUninitialize;
const CoTaskMemFree = win32.system.com.CoTaskMemFree;
const CoCreateInstance = win32.system.com.CoCreateInstance;

pub const S_OK: u32 = 0;
pub const CO_E_NOTINITIALIZED: u32 = 0x800401F0;
pub const E_ACCESSDENIED: u32 = 0x80070005;
pub const E_OUTOFMEMORY: u32 = 0x8007000E;
pub const REGDB_E_CLASSNOTREG: u32 = 0x80040154;

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

    pub var TYPE_NAME: [37:0]u16 = [_:0]u16{'W','i','n','d','o','w','s','.','U','I','.','V','i','e','w','M','a','n','a','g','e','m','e','n','t','.','U','I','S','e','t','t','i','n','g','s',0};
    pub const RUNTIME_NAME: [:0]const u16 = TYPE_NAME[0..];
    pub const IID: Guid = Guid.initString("85361600-1c63-4627-bcb1-3a89e0bc9c55");
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

    pub var TYPE_NAME: [37:0]u16 = [_:0]u16{'W','i','n','d','o','w','s','.','U','I','.','V','i','e','w','M','a','n','a','g','e','m','e','n','t','.','U','I','S','e','t','t','i','n','g','s',0};
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

    pub fn colorValuesChanged(self: *const @This(), handler: *TypedEventHandler(IUISettings3)) !i64 {
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

    pub var TYPE_NAME: [37:0]u16 = [_:0]u16{'W','i','n','d','o','w','s','.','U','I','.','V','i','e','w','M','a','n','a','g','e','m','e','n','t','.','U','I','S','e','t','t','i','n','g','s',0};
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

    pub var TYPE_NAME: [37:0]u16 = [_:0]u16{'W','i','n','d','o','w','s','.','U','I','.','V','i','e','w','M','a','n','a','g','e','m','e','n','t','.','U','I','S','e','t','t','i','n','g','s',0};
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

    pub var TYPE_NAME: [37:0]u16 = [_:0]u16{'W','i','n','d','o','w','s','.','U','I','.','V','i','e','w','M','a','n','a','g','e','m','e','n','t','.','U','I','S','e','t','t','i','n','g','s',0};
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

    pub var TYPE_NAME: [37:0]u16 = [_:0]u16{'W','i','n','d','o','w','s','.','U','I','.','V','i','e','w','M','a','n','a','g','e','m','e','n','t','.','U','I','S','e','t','t','i','n','g','s',0};
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

pub const ITypedEventHandler = extern struct {
    // COM vtable layout
    vtable: *const VTable,

    pub const VTable = extern struct {
        QueryInterface: *const fn(
            self: *anyopaque,
            riid: *const Guid,
            ppvObject: *?*anyopaque,
        ) callconv(.C) HRESULT,
        AddRef: *const fn(
            self: *anyopaque,
        ) callconv(.C) u32,
        Release: *const fn(
            self: *anyopaque,
        ) callconv(.C) u32,

        // Invoke method for the delegate
        Invoke: *const fn(
            self: *ITypedEventHandler,
            sender: *anyopaque,
            args: *anyopaque,
        ) callconv(.C) HRESULT,
    };
};

const IRoMetaDataLocator = extern struct {
    lpVtbl: *VTable,

    const VTable = extern struct {
        QueryInterface: fn(*IRoMetaDataLocator, *Guid, *?*anyopaque) HRESULT,
        AddRef: fn(*IRoMetaDataLocator) u32,
        Release: fn(*IRoMetaDataLocator) u32,
        FindTypeDef: fn(*IRoMetaDataLocator, *HSTRING, *[*:0]u16, u32, ?*[*:0]u16, ?*u32) HRESULT,
    };
};

pub fn TypedEventHandler(I: type) type {
    return extern struct {
        // pub const IID: Guid = Guid.initString("9de1c534-6ae1-11e0-84e1-18a905bcc53f");
        pub const VTABLE = ITypedEventHandler.VTable {
            .QueryInterface = query_interface,
            .AddRef = add_ref,
            .Release = release,
            .Invoke = invoke,
        };

        vtable: *const ITypedEventHandler.VTable,
        refs: std.atomic.Value(u32),
        iid: Guid,
        cb: *const fn (sender: *I) callconv(.C) void,

        var WindowsFoundation: [19:0]u16 = [_:0]u16{'W','i','n','d','o','w','s','.','F','o','u','n','d','a','t','i','o','n',0};
        var TypedEventHandler2: [20:0]u16 = [_:0]u16{'T','y','p','e','d','E','v','e','n','t','H','a','n','d','l','e','r','`','2',0};
        var IInspectable_NAME: [32:0]u16 = [_:0]u16{'W','i','n','d','o','w','s','.','F','o','u','n','d','a','t','i','o','n','.','I','I','n','s','p','e','c','t','a','b','l','e',0};

        pub fn init(callback: *const fn (sender: *I) callconv(.C) void) !@This() {
            var type_names: [4]?*u16 = [_]?*u16{
                &WindowsFoundation[0],
                &TypedEventHandler2[0],
                &I.TYPE_NAME[0],
                &IInspectable_NAME[0],
            };

            var iid: Guid = undefined;
            _ = RoGetParameterizedTypeInstanceIID(
                @intCast(type_names.len),
                type_names[0..].ptr,
                null,
                &iid,
                null,
            );
            std.debug.print("{any}\n", .{ std.mem.toBytes(&iid) });

            return .{
                .vtable = &VTABLE,
                .refs = std.atomic.Value(u32).init(1),
                .iid = iid,
                .cb = callback,
            };
        }

        fn query_interface(self: *anyopaque, riid: *const Guid, out: *?*anyopaque) callconv(.C) HRESULT {
            const me: *@This() = @ptrCast(@alignCast(self));
            // Support IUnknown and (optionally) the exact delegate IID.
            std.debug.print("[TARGET]   {any}\n", .{ std.mem.toBytes(riid) });
            std.debug.print("[EXPECTED] {any}\n", .{ std.mem.toBytes(&me.iid) });
            if (
                std.mem.eql(u8, std.mem.asBytes(riid), std.mem.asBytes(IID_IUnknown))
                or std.mem.eql(u8, std.mem.asBytes(riid), std.mem.asBytes(&me.iid))
            ) {
                std.debug.print("[OK]\n", .{});
                out.* = @as(?*anyopaque, @ptrCast(me));
                _ = add_ref(self);
                return 0; // S_OK
            }
            out.* = null;
            std.debug.print("[NOINTERFACE]\n", .{});
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
            _ = self;
            _ = sender;
            std.debug.print("Color Change", .{});
            // const me: *@This() = @ptrCast(@alignCast(self));
            // var i: ?*I = null;
            // const hr = sender.vtable.base.QueryInterface(@ptrCast(sender), &I.IID, @ptrCast(&i));
            // if (hr > 0 and i != null) {
            //     me.cb(i.?);
            //     _ = @as(*IUnknown, @ptrCast(i.?)).vtable.Release(@ptrCast(i.?));
            // }
            return 0; // S_OK regardless; you usually don’t fail event callbacks
        }
    };
}

pub const UISettings = extern struct {
    pub var TYPE_NAME: [37:0]u16 = [_:0]u16{'W','i','n','d','o','w','s','.','U','I','.','V','i','e','w','M','a','n','a','g','e','m','e','n','t','.','U','I','S','e','t','t','i','n','g','s',0};
    pub const RUNTIME_NAME: [:0]const u16 = TYPE_NAME[0..];

    var Factory: FactoryCache = .{};

    vtable: *const IUISettings,

    pub fn init() anyerror!@This() {
        const inner: *IUISettings = try @This().Factory.call(
            IGenericFactory,
            IUISettings,
            @This().RUNTIME_NAME,
        );
        return .{ .vtable = inner };
    }

    pub fn deinit(self: *const @This()) u32 {
        return self.release();
    }

    pub fn release(self: *const @This()) u32 {
        return self.vtable.release();
    }

    pub fn getColorValue(self: *const @This(), color_type: UIColorType) !Color {
        var instance: *IUISettings3 = undefined;
        if (self.vtable.query_interface(&IUISettings3.IID, @ptrCast(&instance)) < 0) {
            return error.NoInterface;
        }

        return instance.getColorValue(color_type);
    }

    pub fn colorValuesChanged(self: *const @This(), handler: *TypedEventHandler(IUISettings3)) !i64 {
        var instance: *IUISettings3 = undefined;
        if (self.vtable.query_interface(&IUISettings3.IID, @ptrCast(&instance)) < 0) {
            return error.NoInterface;
        }

        return instance.colorValuesChanged(handler);
    }

    pub fn removeColorValuesChanged(self: *const @This(), id: i64) !void {
        var instance: *IUISettings3 = undefined;
        if (self.vtable.query_interface(&IUISettings3.IID, @ptrCast(&instance)) < 0) {
            return error.NoInterface;
        }

        try instance.removeColorValuesChanged(id);
    }
};

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

    while (rfind(u16, path, '.')) |pos| {
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

fn rfind(T: type, source: []const T, match: T) ?usize {
    var i: usize = source.len - 1;
    while (i > 0) : (i -= 1) {
        if (std.meta.eql(source[i], match)) return i;
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
