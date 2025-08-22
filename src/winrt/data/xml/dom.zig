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

pub const IXmlNodeList = extern struct {
    vtable: *const VTable,

    pub const GUID: []const u8 = "8c60ad77-83a4-4ec1-9c54-7ba429e13da6";
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

        // TODO: Fix param types to be correct
        Length: *const fn(*anyopaque, *u32) callconv(.C) HRESULT,
        Item: *const fn(*anyopaque, u32, **anyopaque) callconv(.C) HRESULT,
    };
};

pub const IXmlNodeSelector = extern struct {
    vtable: *const VTable,

    pub const GUID: []const u8 = "63dbba8b-d0db-4fe1-b745-f9433afdc25b";
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

        // TODO: Fix param types to be correct
        SelectSingleNode: *const fn(*anyopaque, *anyopaque, **anyopaque) callconv(.C) HRESULT,
        SelectNodes: *const fn(*anyopaque, *anyopaque, **anyopaque) callconv(.C) HRESULT,
        SelectSingleNodeNS: *const fn(*anyopaque, *anyopaque, *anyopaque, **anyopaque) callconv(.C) HRESULT,
        SelectNodesNS: *const fn(*anyopaque, *anyopaque, *anyopaque, **anyopaque) callconv(.C) HRESULT,
    };
};

// TODO: Implement
// IXmlNode
// IXmlNodeSerializer
// IIterable
// IIterator
// IVectorView
// XmlElement
// XmlNodeList

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

    pub fn load_xml(self: *@This(), xml: [:0]const u16) !void {
        const xml_hstring: ?HSTRING = try winrt.WindowsCreateString(xml);
        defer winrt.WindowsDeleteString(xml_hstring);

        const instance = try self.query_interface(IXmlDocumentIO);
        const code = instance.vtable.LoadXml(@ptrCast(instance), xml_hstring.?);
        if (code < S_OK) {
            return error.XmlException;
        }
    }

    pub fn create_element(self: *@This(), tagname: *HSTRING) !*anyopaque {
        var element: *anyopaque = undefined;
        if (self.vtable.CreateElement(@ptrCast(self), @ptrCast(tagname), &element) < S_OK) {
            return error.ElementException;
        }
        return element;
    }

    // CreateTextNode: *const fn(*anyopaque, *anyopaque, **anyopaque) callconv(.C) HRESULT,
    pub fn create_text_node(self: *@This()) !void {
        _ = self;
    }

    // GetElementsByTagName: *const fn(*anyopaque, *anyopaque, **anyopaque) callconv(.C) HRESULT,
    pub fn get_elements_by_tag_name(self: *@This()) !void {
        _ = self;
    }

    // GetElementById: *const fn(*anyopaque, *anyopaque, **anyopaque) callconv(.C) HRESULT,
    pub fn get_element_by_id(self: *@This()) !void {
        _ = self;
    }
};
