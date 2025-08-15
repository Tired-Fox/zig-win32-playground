const std = @import("std");
const win32 = @import("win32");

pub const IInspectable = win32.system.win_rt.IInspectable;
pub const IUnknown = win32.system.com.IUnknown;
pub const HRESULT = win32.foundation.HRESULT;
pub const Guid = win32.zig.Guid;
pub const HSTRING = win32.system.win_rt.HSTRING;
const WindowsCreateString = win32.system.win_rt.WindowsCreateString;
const WindowsDeleteString = win32.system.win_rt.WindowsDeleteString;
const RoGetActivationFactory = win32.system.win_rt.RoGetActivationFactory;
const RoActivateInstance = win32.system.win_rt.RoActivateInstance;
const CoIncrementMTAUsage = win32.system.com.CoIncrementMTAUsage;

pub const S_OK: u32 = 0;
pub const CO_E_NOTINITIALIZED: u32 = 0x800401F0;
pub const E_ACCESSDENIED: u32 = 0x80070005;
pub const E_OUTOFMEMORY: u32 = 0x8007000E;
pub const REGDB_E_CLASSNOTREG: u32 = 0x80040154;

pub const Error = error {
    /// No interface found for the given action, or the given class does not implement IInspectable
    NoInterface,
    /// The thread has not been initialized in the Windows Runtime by calling RoInitialize
    NotInitialized,
    /// The TrustLevel for the class requires a full-trust process
    AccessDenied,
    OutOfMemory,
};

const IID_IAgileObject = win32.system.com.IID_IAgileObject;

pub const Color = extern struct {
    A: u8,
    R: u8,
    G: u8,
    B: u8
};

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

pub const UISettings = extern struct {
    pub const VTable = extern struct {
        base: IInspectable.VTable,

        HandPreference: *const fn(*UISettings, *HandPreference) callconv(.C) HRESULT,
        CursorSize: *const fn(*UISettings, *win32.foundation.SIZE) callconv(.C) HRESULT,
        ScrollBarSize: *const fn(*UISettings, *win32.foundation.SIZE) callconv(.C) HRESULT,
        ScrollBarArrowSize: *const fn(*UISettings, *win32.foundation.SIZE) callconv(.C) HRESULT,
        ScrollBarThumbBoxSize: *const fn(*UISettings, *win32.foundation.SIZE) callconv(.C) HRESULT,
        MessageDuration: *const fn(*UISettings, *u32) callconv(.C) HRESULT,
        AnimationsEnabled: *const fn(*UISettings, *bool) callconv(.C) HRESULT,
        CaretBrowsingEnabled: *const fn(*UISettings, *bool) callconv(.C) HRESULT,
        CaretBlinkRate: *const fn(*UISettings, *u32) callconv(.C) HRESULT,
        CaretWidth: *const fn(*UISettings, *u32) callconv(.C) HRESULT,
        DoubleClickTime: *const fn(*UISettings, *u32) callconv(.C) HRESULT,
        MouseHoverTime: *const fn(*UISettings, *u32) callconv(.C) HRESULT,
        UIElementColor: *const fn(*UISettings, UIElementType, *Color) callconv(.C) HRESULT,

        TextScaleFactor: *const fn(*UISettings, *f64) callconv(.C) HRESULT,
        TextScaleFactorChanged: *const fn(*UISettings, *IInspectable, *i64) callconv(.C) HRESULT,
        RemoveTextScaleFactorChanged: *const fn(*UISettings, i64) callconv(.C) HRESULT,

        GetColorValue: *const fn(*UISettings, UIColorType, *Color) callconv(.C) HRESULT,
        ColorValuesChanged: *const fn(*UISettings, *IInspectable, *i64) callconv(.C) HRESULT,
        RemoveColorValuesChanged: *const fn(*UISettings, i64) callconv(.C) HRESULT,

        AdvancedEffectsEnabled: *const fn(*UISettings, *bool) callconv(.C) HRESULT,
        AdvancedEffectsEnabledChanged: *const fn(*UISettings, *IInspectable, *i64) callconv(.C) HRESULT,
        RemoveAdvancedEffectsEnabledChanged: *const fn(*UISettings, i64) callconv(.C) HRESULT,

        AutoHideScrollBars: *const fn(*UISettings, *bool) callconv(.C) HRESULT,
        AutoHideScrollBarsChanged: *const fn(*UISettings, *IInspectable, *i64) callconv(.C) HRESULT,
        RemoveAutoHideScrollBarsChanged: *const fn(*UISettings, i64) callconv(.C) HRESULT,

        AnimationsEnabledChanged: *const fn(*UISettings, *IInspectable, *i64) callconv(.C) HRESULT,
        RemoveAnimationsEnabledChanged: *const fn(*UISettings, i64) callconv(.C) HRESULT,
        MessageDurationChanged: *const fn(*UISettings, *IInspectable, *i64) callconv(.C) HRESULT,
        RemoveMessageDurationChanged: *const fn(*UISettings, i64) callconv(.C) HRESULT,
    };

    pub const RUNTIME_NAME: [:0]const u16 = std.unicode.utf8ToUtf16LeStringLiteral("Windows.UI.ViewManagement.UISettings");
    pub const IID: Guid = Guid.initString("85361600-1c63-4627-bcb1-3a89e0bc9c55");

    var Factory: FactoryCache = .{};

    vtable: *const VTable,

    pub fn init() Error!*@This() {
        return @This().Factory.call(@This(), IGenericFactory);
    }

    pub fn deinit(self: *const @This()) u32 {
        return self.Release();
    }

    pub fn Release(self: *const @This()) u32 {
        return self.vtable.base.base.Release(@ptrCast(@alignCast(self)));
    }

    pub fn getColorValue(self: *@This(), color_type: UIColorType) !Color {
        var color: Color = .{
            .A = 0,
            .R = 0,
            .G = 0,
            .B = 0,
        };
        const code = self.vtable.GetColorValue(self, color_type, &color);
        std.debug.print("[0x{X}]: {any}\n", .{code, color});
        return color;
    }
};

pub const IGenericFactory = extern struct {
    pub const VTable = extern struct {
        base: IInspectable.VTable,
        ActivateInstance: *const fn(*IGenericFactory, **anyopaque) callconv(.C) HRESULT
    };

    vtable: *const VTable,

    pub const IID: Guid = Guid.initString("00000035-0000-0000-c000-000000000046");

    pub fn ActivateInstance(self: *IGenericFactory, R: type) Error!*R {
        var result: *R = undefined;
        const code = @as(u32, @bitCast(self.vtable.ActivateInstance(self, @ptrCast(@alignCast(&result)))));
        if (code == S_OK) return result;

        if (code == CO_E_NOTINITIALIZED) return error.NotInitialized
        else if (code == E_ACCESSDENIED) return error.AccessDenied
        else if (code == E_OUTOFMEMORY) return error.OutOfMemory;

        return error.NoInterface;
    }
};

// ALTERNATE METHOD TO INITIALIZING CLASS
// var name: ?HSTRING = undefined;
// if (@as(u32, @bitCast(WindowsCreateString(@This().RUNTIME_NAME.ptr, @This().RUNTIME_NAME.len, &name))) != S_OK) {
//     return error.OutOfMemory;
// }
// defer _ = WindowsDeleteString(name);
//
// var instance: *IInspectable = undefined;
//
// var result = RoActivateInstance(
//     name,
//     &instance
// );
//
// if (@as(u32, @bitCast(result)) == CO_E_NOTINITIALIZED) {
//     var cookie: isize = undefined;
//     _ = CoIncrementMTAUsage(&cookie);
//
//     result = RoActivateInstance(
//         name,
//         &instance
//     );
// }
//
// if (result != S_OK) {
//     std.debug.print("{X}\n", .{@as(u32, @bitCast(result))});
//     return error.NoInterface;
// }
//
// return @ptrCast(@alignCast(instance));

pub const FactoryCache = struct {
    shared: std.atomic.Value(?*anyopaque) = .init(null),

    pub fn call(self: *@This(), R: type, I: type) !*R {
        while (true) {
            // Attempt to load a previously cached factory pointer.
            if (self.shared.load(.acquire)) |ptr| {
                // If a pointer is found, the cache is primed and we're good to go.
                return try I.ActivateInstance(@ptrCast(@alignCast(ptr)), R);
            }

            // Otherwise, we load the factory the usual way.
            const factory = try load_factory(R, I);

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

fn load_factory(R: type, I: type) Error!*anyopaque {
    const interface_name: [:0]const u16 = R.RUNTIME_NAME;
    const interface_iid: *const Guid = &I.IID;

    var factory: *anyopaque = undefined;

    var name: ?HSTRING = undefined;
    if (@as(u32, @bitCast(WindowsCreateString(interface_name.ptr, interface_name.len, &name))) != S_OK) {
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
            _ = CoIncrementMTAUsage(&cookie);

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
        if (try searchPath(interface_name, &name)) |i| {
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
    var path: [:0]const u16 = runtime_path[0..];

    while (rfind(u16, path[0..], '.')) |pos| {
        path = path[0..pos:0];

        var library: [:0]u16 = std.heap.smp_allocator.allocSentinel(u16, path.len + suffix.len, 0) catch return error.OutOfMemory;
        defer std.heap.smp_allocator.free(library);

        @memcpy(library, path);
        @memcpy(library[path.len..], suffix);

        if (getActivationFactory(library.ptr, name)) |r| {
            return r;
        }
    }
    return null;
}

fn rfind(T: type, source: []const T, match: T) ?usize {
    var i: usize = source.len;
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

const DllGetActivationFactory = *const fn(name: *anyopaque, factory: **anyopaque) HRESULT;
const DllGetActivationFactoryName: [:0]const u8 = "DllGetActivationFactory";
