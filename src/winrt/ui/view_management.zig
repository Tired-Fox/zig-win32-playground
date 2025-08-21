const core = @import("../core.zig");
const std = @import("std");
const winrt = @import("../../winrt.zig");
const win32 = @import("win32");

const Color = winrt.ui.Color;
const FactoryCache = core.FactoryCache;
const Guid = win32.zig.Guid;
const HRESULT = win32.foundation.HRESULT;
const HSTRING = win32.system.win_rt.HSTRING;
const IGenericFactory = core.IGenericFactory;
const IInspectable = win32.system.win_rt.IInspectable;
const ITypedEventHandler = winrt.foundation.ITypedEventHandler;
const TrustLevel = win32.system.win_rt.TrustLevel;
const TypedEventHandler = winrt.foundation.TypedEventHandler;

pub const HandPreference = enum(i32) {
    left_handed = 0,
    right_handed = 1,
};

pub const UIElementType = enum(i32) {
    active_caption = 0,
    background = 1,
    button_face = 2,
    button_text = 3,
    caption_text = 4,
    gray_text = 5,
    highlight = 6,
    highlight_text = 7,
    hotlight = 8,
    inactive_caption = 9,
    inactive_caption_text = 10,
    window = 11,
    window_text = 12,
    accent_color = 1000,
    text_high = 1001,
    text_medium = 1002,
    text_low = 1003,
    text_contrast_with_high = 1004,
    non_text_high = 1005,
    non_text_medium_high = 1006,
    non_text_medium = 1007,
    non_text_medium_low = 1008,
    non_text_low = 1009,
    page_background = 1010,
    popup_background = 1011,
    overlay_outside_popup = 1012,
};

pub const UIColorType = enum(i32) {
    background = 0,
    foreground = 1,
    accent_dark_3 = 2,
    accent_dark_2 = 3,
    accent_dark_1 = 4,
    accent = 5,
    accent_light_1 = 6,
    accent_light_2 = 7,
    accent_light_3 = 8,
    complement = 9,
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
