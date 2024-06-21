const std = @import("std");
const raylib = @cImport({
    @cInclude("raylib.h");
});

var libplug: std.DynLib = undefined;
const libplug_path = "libplug.so";

var plug_init: *const fn () void = undefined;
var plug_destroy: *const fn () void = undefined;
var plug_pre_reload: *const fn () *anyopaque = undefined;
var plug_post_reload: *const fn (*anyopaque) void = undefined;
var plug_update: *const fn () void = undefined;

pub fn main() !void {
    if (!reload_plugin()) {
        return error.PluginLoadFailed;
    }

    plug_init();
    defer plug_destroy();
    raylib.InitWindow(800, 600, "Hot reloading");
    defer raylib.CloseWindow();

    while (!raylib.WindowShouldClose()) {
        if (raylib.IsKeyPressed(raylib.KEY_R)) {
            const state: *anyopaque = plug_pre_reload();
            if (!reload_plugin()) {
                return error.PluginLoadFailed;
            }
            plug_post_reload(state);
        }

        plug_update();
    }

    if (!unload_plugin()) {
        return error.PluginUnloadFailed;
    }
}

fn reload_plugin() bool {
    if (libplug != undefined) {
        std.DynLib.close(libplug);
    }

    libplug = std.DynLib.open(libplug_path) catch {
        return false;
    };

    plug_init = libplug.lookup(@TypeOf(plug_init), "plug_init") orelse return false;
    plug_destroy = libplug.lookup(@TypeOf(plug_destroy), "plug_destroy") orelse return false;
    plug_pre_reload = libplug.lookup(@TypeOf(plug_pre_reload), "plug_pre_reload") orelse return false;
    plug_post_reload = libplug.lookup(@TypeOf(plug_post_reload), "plug_post_reload") orelse return false;
    plug_update = libplug.lookup(@TypeOf(plug_update), "plug_update") orelse return false;

    return true;
}

fn unload_plugin() bool {
    if (libplug != undefined) {
        std.DynLib.close(libplug);
        libplug = undefined;
    }
    return true;
}
