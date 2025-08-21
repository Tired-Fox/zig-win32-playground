pub const core = @import("../core.zig");
pub const std = @import("std");
pub const win32 = @import("win32");
pub const winrt = @import("../../winrt.zig");

const ITypedEventHandler = winrt.foundation.ITypedEventHandler;
const XmlDocument = winrt.data.xml.dom.XmlDocument;

pub const Guid = win32.zig.Guid;
pub const HRESULT = win32.foundation.HRESULT;
pub const HSTRING = win32.system.win_rt.HSTRING;

pub const FactoryCache = core.FactoryCache;
pub const FactoryError = core.FactoryError;
pub const IGenericFactory = core.IGenericFactory;

pub const S_OK = winrt.S_OK;

pub const IToastNotification = extern struct {
    vtable: *const VTable,

    pub const GUID: []const u8 = "997e2675-059e-4e60-8b06-1760917c8b80";
    pub const IID: Guid = Guid.initString(GUID);
    pub const SIGNATURE: []const u8 = std.fmt.comptimePrint("{{{s}}}", .{ GUID });

    pub const VTable = extern struct {
        // IUnknown
        QueryInterface: *const fn(self: *const anyopaque, riid:*const Guid, out:**anyopaque) callconv(.C) HRESULT,
        AddRef:         *const fn(self: *const anyopaque) callconv(.C) u32,
        Release:        *const fn(self: *const anyopaque) callconv(.C) u32,

        // IInspectable
        GetIids:             *const fn(self: *const anyopaque, count: *u32, iids: *?*Guid) callconv(.C) HRESULT,
        GetRuntimeClassName: *const fn(self: *const anyopaque, s: *HSTRING) callconv(.C) HRESULT,
        GetTrustLevel:       *const fn(self: *const anyopaque, trust: *i32) callconv(.C) HRESULT,

        // TODO: Update these params to be the correct types
        Content: *const fn(*anyopaque, **XmlDocument) callconv(.C) HRESULT,
        SetExpirationTime: *const fn(*anyopaque, ?*anyopaque) callconv(.C) HRESULT,
        ExpirationTime: *const fn(*anyopaque, *?*anyopaque) callconv(.C) HRESULT,
        Dismissed: *const fn(*anyopaque, *ITypedEventHandler, *i64) callconv(.C) HRESULT,
        RemoveDismissed: *const fn(*anyopaque, i64) callconv(.C) HRESULT,
        Activated: *const fn(*anyopaque, *ITypedEventHandler, *i64) callconv(.C) HRESULT,
        RemoveActivated: *const fn(*anyopaque, i64) callconv(.C) HRESULT,
        Failed: *const fn(*anyopaque, *ITypedEventHandler, *i64) callconv(.C) HRESULT,
        RemoveFailed: *const fn(*anyopaque, i64) callconv(.C) HRESULT,
    };
};

pub const IToastNotification2 = extern struct {
    vtable: *const VTable,

    pub const GUID: []const u8 = "9dfb9fd1-143a-490e-90bf-b9fba7132de7";
    pub const IID: Guid = Guid.initString(GUID);
    pub const SIGNATURE: []const u8 = std.fmt.comptimePrint("{{{s}}}", .{ GUID });

    pub const VTable = extern struct {
        // IUnknown
        QueryInterface: *const fn(self: *const anyopaque, riid:*const Guid, out:**anyopaque) callconv(.C) HRESULT,
        AddRef:         *const fn(self: *const anyopaque) callconv(.C) u32,
        Release:        *const fn(self: *const anyopaque) callconv(.C) u32,

        // IInspectable
        GetIids:             *const fn(self: *const anyopaque, count: *u32, iids: *?*Guid) callconv(.C) HRESULT,
        GetRuntimeClassName: *const fn(self: *const anyopaque, s: *HSTRING) callconv(.C) HRESULT,
        GetTrustLevel:       *const fn(self: *const anyopaque, trust: *i32) callconv(.C) HRESULT,

        // TODO: Update these params to be the correct types
        SetTag: *const fn(*anyopaque, *anyopaque) callconv(.C) HRESULT,
        Tag: *const fn(*anyopaque, **anyopaque) callconv(.C) HRESULT,
        SetGroup: *const fn(*anyopaque, *anyopaque) callconv(.C) HRESULT,
        Group: *const fn(*anyopaque, **anyopaque) callconv(.C) HRESULT,
        SetSuppressPopup: *const fn(*anyopaque, bool) callconv(.C) HRESULT,
        SuppressPopup: *const fn(*anyopaque, *bool) callconv(.C) HRESULT,
    };
};

pub const IToastNotification3 = extern struct {
    vtable: *const VTable,

    pub const GUID: []const u8 = "15154935-28ea-4727-88e9-c58680e2d118";
    pub const IID: Guid = Guid.initString(GUID);
    pub const SIGNATURE: []const u8 = std.fmt.comptimePrint("{{{s}}}", .{ GUID });

    pub const VTable = extern struct {
        // IUnknown
        QueryInterface: *const fn(self: *const anyopaque, riid:*const Guid, out:**anyopaque) callconv(.C) HRESULT,
        AddRef:         *const fn(self: *const anyopaque) callconv(.C) u32,
        Release:        *const fn(self: *const anyopaque) callconv(.C) u32,

        // IInspectable
        GetIids:             *const fn(self: *const anyopaque, count: *u32, iids: *?*Guid) callconv(.C) HRESULT,
        GetRuntimeClassName: *const fn(self: *const anyopaque, s: *HSTRING) callconv(.C) HRESULT,
        GetTrustLevel:       *const fn(self: *const anyopaque, trust: *i32) callconv(.C) HRESULT,

        // TODO: Update these params to be the correct types
        NotificationMirroring: *const fn(*anyopaque, *NotificationMirroring) callconv(.C) HRESULT,
        SetNotificationMirroring: *const fn(*anyopaque, NotificationMirroring) callconv(.C) HRESULT,
        RemoteId: *const fn(*anyopaque, **anyopaque) callconv(.C) HRESULT,
        SetRemoteId: *const fn(*anyopaque, *anyopaque) callconv(.C) HRESULT,
    };
};

pub const IToastNotification4 = extern struct {
    vtable: *const VTable,

    pub const GUID: []const u8 = "15154935-28ea-4727-88e9-c58680e2d118";
    pub const IID: Guid = Guid.initString(GUID);
    pub const SIGNATURE: []const u8 = std.fmt.comptimePrint("{{{s}}}", .{ GUID });

    pub const VTable = extern struct {
        // IUnknown
        QueryInterface: *const fn(self: *const anyopaque, riid:*const Guid, out:**anyopaque) callconv(.C) HRESULT,
        AddRef:         *const fn(self: *const anyopaque) callconv(.C) u32,
        Release:        *const fn(self: *const anyopaque) callconv(.C) u32,

        // IInspectable
        GetIids:             *const fn(self: *const anyopaque, count: *u32, iids: *?*Guid) callconv(.C) HRESULT,
        GetRuntimeClassName: *const fn(self: *const anyopaque, s: *HSTRING) callconv(.C) HRESULT,
        GetTrustLevel:       *const fn(self: *const anyopaque, trust: *i32) callconv(.C) HRESULT,

        // TODO: Update these params to be the correct types
        Data: *const fn(*anyopaque, **anyopaque) callconv(.C) HRESULT,
        SetData: *const fn(*anyopaque, *anyopaque) callconv(.C) HRESULT,
        Priority: *const fn(*anyopaque, *ToastNotificationPriority) callconv(.C) HRESULT,
        SetPriority: *const fn(*anyopaque, ToastNotificationPriority) callconv(.C) HRESULT,
    };
};

pub const IToastNotification6 = extern struct {
    vtable: *const VTable,

    pub const GUID: []const u8 = "43ebfe53-89ae-5c1e-a279-3aecfe9b6f54";
    pub const IID: Guid = Guid.initString(GUID);
    pub const SIGNATURE: []const u8 = std.fmt.comptimePrint("{{{s}}}", .{ GUID });

    pub const VTable = extern struct {
        // IUnknown
        QueryInterface: *const fn(self: *const anyopaque, riid:*const Guid, out:**anyopaque) callconv(.C) HRESULT,
        AddRef:         *const fn(self: *const anyopaque) callconv(.C) u32,
        Release:        *const fn(self: *const anyopaque) callconv(.C) u32,

        // IInspectable
        GetIids:             *const fn(self: *const anyopaque, count: *u32, iids: *?*Guid) callconv(.C) HRESULT,
        GetRuntimeClassName: *const fn(self: *const anyopaque, s: *HSTRING) callconv(.C) HRESULT,
        GetTrustLevel:       *const fn(self: *const anyopaque, trust: *i32) callconv(.C) HRESULT,

        // TODO: Update these params to be the correct types
        ExpiresOnReboot: *const fn(*anyopaque, *bool) callconv(.C) HRESULT,
        SetExpiresOnReboot: *const fn(*anyopaque, bool) callconv(.C) HRESULT,
    };
};

pub const IToastNotificationFactory = extern struct {
    vtable: *const VTable,

    pub const GUID: []const u8 = "04124b20-82c6-4229-b109-fd9ed4662b53";
    pub const IID: Guid = Guid.initString(GUID);
    pub const SIGNATURE: []const u8 = std.fmt.comptimePrint("{{{s}}}", .{ GUID });

    pub fn create_toast_notification(self: *@This(), xml: *XmlDocument) !*ToastNotification {

    }

    pub const VTable = extern struct {
        // IUnknown
        QueryInterface: *const fn(self: *const anyopaque, riid:*const Guid, out:**anyopaque) callconv(.C) HRESULT,
        AddRef:         *const fn(self: *const anyopaque) callconv(.C) u32,
        Release:        *const fn(self: *const anyopaque) callconv(.C) u32,

        // IInspectable
        GetIids:             *const fn(self: *const anyopaque, count: *u32, iids: *?*Guid) callconv(.C) HRESULT,
        GetRuntimeClassName: *const fn(self: *const anyopaque, s: *HSTRING) callconv(.C) HRESULT,
        GetTrustLevel:       *const fn(self: *const anyopaque, trust: *i32) callconv(.C) HRESULT,

        CreateToastNotification: *const fn(*anyopaque, *const XmlDocument, **ToastNotification) callconv(.C) HRESULT
    };
};

// // ToastNotifier (Show/Hide)
// pub const IToastNotifierVTable = extern struct {
//     // IInspectable
//     QueryInterface: *const fn(*anyopaque, *const GUID, *?*anyopaque) callconv(.C) HRESULT,
//     AddRef:         *const fn(*anyopaque) callconv(.C) u32,
//     Release:        *const fn(*anyopaque) callconv(.C) u32,
//     GetIids:             *const fn(*anyopaque, *u32, *?*GUID) callconv(.C) HRESULT,
//     GetRuntimeClassName: *const fn(*anyopaque, *HSTRING) callconv(.C) HRESULT,
//     GetTrustLevel:       *const fn(*anyopaque, *i32) callconv(.C) HRESULT,
//
//     Show: *const fn(self:*anyopaque, toast: *IToastNotification) callconv(.C) HRESULT,
//     // Hide: *const fn(self:*anyopaque, toast: *IToastNotification) callconv(.C) HRESULT,
// };
// pub const IToastNotifier = extern struct { lpVtbl: *const IToastNotifierVTable; };
//
// const RC_ToastNotificationManager  = "Windows.UI.Notifications.ToastNotificationManager";
// // ToastNotificationManager statics
// // ToastNotificationManager is static → RoGetActivationFactory.
// pub const IToastNotificationManagerStaticsVTable = extern struct {
//     // IInspectable
//     QueryInterface: *const fn(*anyopaque, *const GUID, *?*anyopaque) callconv(.C) HRESULT,
//     AddRef:         *const fn(*anyopaque) callconv(.C) u32,
//     Release:        *const fn(*anyopaque) callconv(.C) u32,
//     GetIids:             *const fn(*anyopaque, *u32, *?*GUID) callconv(.C) HRESULT,
//     GetRuntimeClassName: *const fn(*anyopaque, *HSTRING) callconv(.C) HRESULT,
//     GetTrustLevel:       *const fn(*anyopaque, *i32) callconv(.C) HRESULT,
//
//     // For packaged apps: CreateToastNotifier(out)
//     CreateToastNotifier: *const fn(self:*anyopaque, out: *?*IToastNotifier) callconv(.C) HRESULT,
//
//     // (Often also GetTemplateContent, etc. — add if you want)
// };
// pub const IToastNotificationManagerStatics = extern struct { lpVtbl: *const IToastNotificationManagerStaticsVTable; };
//
// // Desktop/unpackaged overload lives on *Statics2*: CreateToastNotifierWithId(appId, out)
// pub const IToastNotificationManagerStatics2VTable = extern struct {
//     // IInspectable
//     QueryInterface: *const fn(*anyopaque, *const GUID, *?*anyopaque) callconv(.C) HRESULT,
//     AddRef:         *const fn(*anyopaque) callconv(.C) u32,
//     Release:        *const fn(*anyopaque) callconv(.C) u32,
//     GetIids:             *const fn(*anyopaque, *u32, *?*GUID) callconv(.C) HRESULT,
//     GetRuntimeClassName: *const fn(*anyopaque, *HSTRING) callconv(.C) HRESULT,
//     GetTrustLevel:       *const fn(*anyopaque, *i32) callconv(.C) HRESULT,
//
//     CreateToastNotifierWithId: *const fn(self:*anyopaque, appId: HSTRING, out: *?*IToastNotifier) callconv(.C) HRESULT,
// };
// pub const IToastNotificationManagerStatics2 = extern struct { lpVtbl: *const IToastNotificationManagerStatics2VTable; };

pub const ToastNotificationPriority = enum(i32) {
    default = 0,
    high = 1,
};

pub const NotificationMirroring = enum(i32) {
    allowed = 0,
    disabled = 1,
};

pub const ToastNotification = extern struct {
    vtable: *IToastNotification.VTable,

    pub const TYPE_NAME: []const u8 = "Windows.UI.Notifications.ToastNotification";
    pub const SIGNATURE: []const u8 = std.fmt.comptimePrint("rc({s};{s})", .{ TYPE_NAME, IToastNotification.SIGNATURE });
    pub const RUNTIME_NAME: [:0]const u16 = std.unicode.utf8ToUtf16LeStringLiteral(TYPE_NAME);

    var Factory: FactoryCache = .{};

    pub fn init() FactoryError!*@This() {
        const inner: *IToastNotification = try @This().Factory.call(
            IGenericFactory,
            IToastNotification,
            @This().RUNTIME_NAME,
        );
        return @ptrCast(@alignCast(inner));
    }

    pub fn deinit(self: *const @This()) void {
        _ = self.release();
    }

    fn query_interface(self: *@This(), I: type) !*I {
        var result: *anyopaque = undefined;
        if (self.vtable.QueryInterface(@ptrCast(self), &I.IID, &result) < S_OK) {
            return error.NoInterface;
        }
        return @ptrCast(@alignCast(result));
    }

    pub fn release(self: *const @This()) u32 {
        return self.vtable.Release(@ptrCast(self));
    }

    pub fn create_toast_notification(xml: *XmlDocument) !*@This() {
        const factory: *IToastNotificationFactory = try @This().Factory.call(
            IToastNotificationFactory,
            @This().RUNTIME_NAME,
        );

        var result: *@This() = undefined;
        if (factory.vtable.CreateToastNotification(@ptrCast(factory), xml, &result) < S_OK) {
            return error.ToastCreationFailure;
        }

        return result;
    }
};
