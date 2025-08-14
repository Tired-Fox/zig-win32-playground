const registry = @import("win32").system.registry;

pub fn isLightTheme() error{ RegRead, RegNotFound, SystemError }!bool {
    var data_type: u32 = 0;
    var data: [4:0]u8 = [_:0]u8{0} ** 4;
    var length: u32 = 4;

    const code = registry.RegGetValueA(
        registry.HKEY_CURRENT_USER,
        "Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize",
        "AppsUseLightTheme",
        registry.RRF_RT_REG_DWORD,
        &data_type,
        @ptrCast(@alignCast(&data)),
        &length,
    );

    switch (code) {
        .NO_ERROR => return data[0] == 1,
        .ERROR_MORE_DATA => return error.RegRead,
        .ERROR_FILE_NOT_FOUND => return error.RegNotFound,
        else => return error.SystemError,
    }
}
