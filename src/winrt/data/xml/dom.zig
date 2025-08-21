const core = @import("../../core.zig");
const std = @import("std");
const win32 = @import("win32");
const winrt = @import("../../../winrt.zig");

const Guid = win32.zig.Guid;
const HRESULT = win32.foundation.HRESULT;
const HSTRING = win32.system.win_rt.HSTRING;

const FactoryCache = core.FactoryCache;
const FactoryError = core.FactoryError;
const IGenericFactory = core.IGenericFactory;

const S_OK = winrt.S_OK;

pub const IXmlDocument = extern struct {
    vtable: *const VTable,

    pub const GUID: []const u8 = "f7f3a506-1e87-42d6-bcfb-b8c809fa5494";
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

        Doctype: *const fn(*anyopaque, **anyopaque) callconv(.C) HRESULT,
        Implementation: *const fn(*anyopaque, **anyopaque) callconv(.C) HRESULT,
        DocumentElement: *const fn(*anyopaque, **anyopaque) callconv(.C) HRESULT,
        CreateElement: *const fn(*anyopaque, *anyopaque, **anyopaque) callconv(.C) HRESULT,
        CreateDocumentFragment: *const fn(*anyopaque, **anyopaque) callconv(.C) HRESULT,
        CreateTextNode: *const fn(*anyopaque, *anyopaque, **anyopaque) callconv(.C) HRESULT,
        CreateComment: *const fn(*anyopaque, *anyopaque, **anyopaque) callconv(.C) HRESULT,
        CreateProcessingInstruction: *const fn(*anyopaque, *anyopaque, *anyopaque, **anyopaque) callconv(.C) HRESULT,
        CreateAttribute: *const fn(*anyopaque, *anyopaque, **anyopaque) callconv(.C) HRESULT,
        CreateEntityReference: *const fn(*anyopaque, *anyopaque, **anyopaque) callconv(.C) HRESULT,
        GetElementsByTagName: *const fn(*anyopaque, *anyopaque, **anyopaque) callconv(.C) HRESULT,
        CreateCDataSection: *const fn(*anyopaque, *anyopaque, **anyopaque) callconv(.C) HRESULT,
        DocumentUri: *const fn(*anyopaque, **anyopaque) callconv(.C) HRESULT,
        CreateAttributeNS: *const fn(*anyopaque, *anyopaque, *anyopaque, **anyopaque) callconv(.C) HRESULT,
        CreateElementNS: *const fn(*anyopaque, *anyopaque, *anyopaque, **anyopaque) callconv(.C) HRESULT,
        GetElementById: *const fn(*anyopaque, *anyopaque, **anyopaque) callconv(.C) HRESULT,
        ImportNode: *const fn(*anyopaque, *anyopaque, bool, **anyopaque) callconv(.C) HRESULT,
    };
};

pub const IXmlDocumentFragment = extern struct {
    vtable: *const VTable,

    pub const GUID: []const u8 = "e2ea6a96-0c21-44a5-8bc9-9e4a262708ec";
    pub const IID: Guid = Guid.initString(GUID);
    pub const SIGNATURE: []const u8 = std.fmt.comptimePrint("{{{s}}}", .{ GUID });

    pub const VTable = extern struct {
        // IUnknown
        QueryInterface: *const fn(self: *anyopaque, riid:*const Guid, out:**anyopaque) callconv(.C) HRESULT,
        AddRef:         *const fn(self: *anyopaque) callconv(.C) u32,
        Release:        *const fn(self: *anyopaque) callconv(.C) u32,

        // IInspectable
        GetIids:             *const fn(self: *anyopaque, count: *u32, iids: *?*Guid) callconv(.C) HRESULT,
        GetRuntimeClassName: *const fn(self: *anyopaque, s: *HSTRING) callconv(.C) HRESULT,
        GetTrustLevel:       *const fn(self: *anyopaque, trust: *i32) callconv(.C) HRESULT,
    };
};

pub const IXmlDocumentIO = extern struct {
    vtable: *const VTable,

    pub const GUID: []const u8 = "6cd0e74e-ee65-4489-9ebf-ca43e87ba637";
    pub const IID: Guid = Guid.initString(GUID);
    pub const SIGNATURE: []const u8 = std.fmt.comptimePrint("{{{s}}}", .{ GUID });

    pub const VTable = extern struct {
        // IUnknown
        QueryInterface: *const fn(self: *anyopaque, riid:*const Guid, out:**anyopaque) callconv(.C) HRESULT,
        AddRef:         *const fn(self: *anyopaque) callconv(.C) u32,
        Release:        *const fn(self: *anyopaque) callconv(.C) u32,

        // IInspectable
        GetIids:             *const fn(self: *anyopaque, count: *u32, iids: *?*Guid) callconv(.C) HRESULT,
        GetRuntimeClassName: *const fn(self: *anyopaque, s: *HSTRING) callconv(.C) HRESULT,
        GetTrustLevel:       *const fn(self: *anyopaque, trust: *i32) callconv(.C) HRESULT,

        LoadXml: *const fn(*anyopaque, HSTRING) callconv(.C) HRESULT,
        LoadXmlWithSettings: *const fn(*anyopaque, HSTRING, *anyopaque) callconv(.C) HRESULT,
        SaveToFileAsync: *const fn(*anyopaque, *anyopaque, **anyopaque) callconv(.C) HRESULT,
    };
};

pub const IXmlDocumentIO2 = extern struct {
    vtable: *const VTable,

    pub const GUID: []const u8 = "5d034661-7bd8-4ad5-9ebf-81e6347263b1";
    pub const IID: Guid = Guid.initString(GUID);
    pub const SIGNATURE: []const u8 = std.fmt.comptimePrint("{{{s}}}", .{ GUID });

    pub const VTable = extern struct {
        // IUnknown
        QueryInterface: *const fn(self: *anyopaque, riid:*const Guid, out:**anyopaque) callconv(.C) HRESULT,
        AddRef:         *const fn(self: *anyopaque) callconv(.C) u32,
        Release:        *const fn(self: *anyopaque) callconv(.C) u32,

        // IInspectable
        GetIids:             *const fn(self: *anyopaque, count: *u32, iids: *?*Guid) callconv(.C) HRESULT,
        GetRuntimeClassName: *const fn(self: *anyopaque, s: *HSTRING) callconv(.C) HRESULT,
        GetTrustLevel:       *const fn(self: *anyopaque, trust: *i32) callconv(.C) HRESULT,

        LoadXmlFromBuffer: *const fn(*anyopaque, *anyopaque) callconv(.C) HRESULT,
        LoadXmlFromBufferWithSettings: *const fn(*anyopaque, *anyopaque, *anyopaque) callconv(.C) HRESULT,
    };
};

pub const IXmlDocumentStatics = extern struct {
    vtable: *const VTable,

    pub const GUID: []const u8 = "5543d254-d757-4b79-9539-232b18f50bf1";
    pub const IID: Guid = Guid.initString(GUID);
    pub const SIGNATURE: []const u8 = std.fmt.comptimePrint("{{{s}}}", .{ GUID });

    pub const VTable = extern struct {
        // IUnknown
        QueryInterface: *const fn(self: *anyopaque, riid:*const Guid, out:**anyopaque) callconv(.C) HRESULT,
        AddRef:         *const fn(self: *anyopaque) callconv(.C) u32,
        Release:        *const fn(self: *anyopaque) callconv(.C) u32,

        // IInspectable
        GetIids:             *const fn(self: *anyopaque, count: *u32, iids: *?*Guid) callconv(.C) HRESULT,
        GetRuntimeClassName: *const fn(self: *anyopaque, s: *HSTRING) callconv(.C) HRESULT,
        GetTrustLevel:       *const fn(self: *anyopaque, trust: *i32) callconv(.C) HRESULT,

        LoadFromUriAsync: *const fn(*anyopaque, *anyopaque, **anyopaque) callconv(.C) HRESULT,
        LoadFromUriWithSettingsAsync: *const fn(*anyopaque, *anyopaque, *anyopaque, **anyopaque) callconv(.C) HRESULT,
        LoadFromFileAsync: *const fn(*anyopaque, *anyopaque, **anyopaque) callconv(.C) HRESULT,
        LoadFromFileWithSettingsAsync: *const fn(*anyopaque, *anyopaque, *anyopaque, **anyopaque) callconv(.C) HRESULT,
    };
};

pub const IXmlDocumentType = extern struct {
    vtable: *const VTable,

    pub const GUID: []const u8 = "f7342425-9781-4964-8e94-9b1c6dfc9bc7";
    pub const IID: Guid = Guid.initString(GUID);
    pub const SIGNATURE: []const u8 = std.fmt.comptimePrint("{{{s}}}", .{ GUID });

    pub const VTable = extern struct {
        // IUnknown
        QueryInterface: *const fn(self: *anyopaque, riid:*const Guid, out:**anyopaque) callconv(.C) HRESULT,
        AddRef:         *const fn(self: *anyopaque) callconv(.C) u32,
        Release:        *const fn(self: *anyopaque) callconv(.C) u32,

        // IInspectable
        GetIids:             *const fn(self: *anyopaque, count: *u32, iids: *?*Guid) callconv(.C) HRESULT,
        GetRuntimeClassName: *const fn(self: *anyopaque, s: *HSTRING) callconv(.C) HRESULT,
        GetTrustLevel:       *const fn(self: *anyopaque, trust: *i32) callconv(.C) HRESULT,

        Name: *const fn(*anyopaque, **anyopaque) callconv(.C) HRESULT,
        Entities: *const fn(*anyopaque, **anyopaque) callconv(.C) HRESULT,
        Notations: *const fn(*anyopaque, **anyopaque) callconv(.C) HRESULT,
    };
};

pub const IXmlDomImplementation = extern struct {
    vtable: *const VTable,

    pub const GUID: []const u8 = "6de58132-f11d-4fbb-8cc6-583cba93112f";
    pub const IID: Guid = Guid.initString(GUID);
    pub const SIGNATURE: []const u8 = std.fmt.comptimePrint("{{{s}}}", .{ GUID });

    pub const VTable = extern struct {
        // IUnknown
        QueryInterface: *const fn(self: *anyopaque, riid:*const Guid, out:**anyopaque) callconv(.C) HRESULT,
        AddRef:         *const fn(self: *anyopaque) callconv(.C) u32,
        Release:        *const fn(self: *anyopaque) callconv(.C) u32,

        // IInspectable
        GetIids:             *const fn(self: *anyopaque, count: *u32, iids: *?*Guid) callconv(.C) HRESULT,
        GetRuntimeClassName: *const fn(self: *anyopaque, s: *HSTRING) callconv(.C) HRESULT,
        GetTrustLevel:       *const fn(self: *anyopaque, trust: *i32) callconv(.C) HRESULT,

        HasFeature: *const fn(*anyopaque, *anyopaque, *anyopaque, *bool) callconv(.C) HRESULT,
    };
};

/// Represents an XML document. You can use this class to load, validate, edit, add, and position XML
/// in a document.
///
/// https://learn.microsoft.com/en-us/dotnet/api/system.xml.xmldocument?view=net-9.0
pub const XmlDocument = extern struct {
    vtable: *IXmlDocument.VTable,

    pub const TYPE_NAME: []const u8 = "Windows.Data.Xml.Dom.XmlDocument";
    pub const SIGNATURE: []const u8 = std.fmt.comptimePrint("rc({s};{s})", .{ TYPE_NAME, IXmlDocument.SIGNATURE });
    pub const RUNTIME_NAME: [:0]const u16 = std.unicode.utf8ToUtf16LeStringLiteral(TYPE_NAME);

    var Factory: FactoryCache = .{};

    pub fn init() FactoryError!*@This() {
        const factory: *IGenericFactory = try @This().Factory.call(
            IGenericFactory,
            @This().RUNTIME_NAME,
        );

        return @ptrCast(@alignCast(try factory.ActivateInstance(IXmlDocument)));
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

    pub fn create_element(self: *@This(), tagname: *HSTRING) !*anyopaque {
        var element: *anyopaque = undefined;
        if (self.vtable.CreateElement(@ptrCast(self), @ptrCast(tagname), &element) < S_OK) {
            return error.ElementException;
        }
        return element;
    }

    pub fn load_xml(self: *@This(), xml: HSTRING) !void {
        const instance = try self.query_interface(IXmlDocumentIO);
        const code = instance.vtable.LoadXml(@ptrCast(instance), xml);
        if (code < S_OK) {
            if (winrt.GetRestrictedErrorInfo()) |info| {
                var result: HRESULT = 0;
                var description: ?*u16 = undefined;
                if (info.GetErrorDetails(&description, &result, null, null) == S_OK) {
                    if (description) |d| {
                        const message: [*:0]const u16 = @ptrCast(d);
                        const m = std.unicode.utf16LeToUtf8Alloc(std.heap.smp_allocator, std.mem.sliceTo(message, 0)) catch unreachable;
                        defer std.heap.smp_allocator.free(m);
                        std.debug.print("[0x{X}] {s}\n", .{ result, m });
                    } else {
                        std.debug.print("[0x{X}]\n", .{ result });
                    }
                }
            }

            return error.XmlException;
        }
    }
};
