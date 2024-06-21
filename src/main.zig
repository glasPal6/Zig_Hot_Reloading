const std = @import("std");

const hotreload = @import("hotreload.zig");
const raylib = @cImport({
    @cInclude("raylib.h");
});

pub fn main() !void {
    if (!hotreload.reload_plugin()) {
        return error.PluginLoadFailed;
    }
    defer _ = hotreload.unload_plugin();

    hotreload.plug_init();
    defer hotreload.plug_destroy();
    raylib.InitWindow(800, 600, "Hot reloading");
    defer raylib.CloseWindow();

    while (!raylib.WindowShouldClose()) {
        if (raylib.IsKeyPressed(raylib.KEY_R)) {
            const state: *anyopaque = hotreload.plug_pre_reload();
            if (!hotreload.reload_plugin()) {
                return error.PluginLoadFailed;
            }
            hotreload.plug_post_reload(state);
        }

        hotreload.plug_update();
    }
}
