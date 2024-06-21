const std = @import("std");
const raylib = @cImport({
    @cInclude("raylib.h");
});

const libplug_path = "zig-out/lib/libplug.so";
var libplug: ?std.DynLib = null;

var plug_init: *const fn () void = undefined;
var plug_destroy: *const fn () void = undefined;
var plug_pre_reload: *const fn () *anyopaque = undefined;
var plug_post_reload: *const fn (*anyopaque) void = undefined;
var plug_update: *const fn () void = undefined;

pub fn main() !void {
    if (!reload_plugin()) {
        return error.PluginLoadFailed;
    }
    defer _ = unload_plugin();

    plug_init();
    defer plug_destroy();
    raylib.InitWindow(800, 600, "Hot reloading");
    defer raylib.CloseWindow();

    while (!raylib.WindowShouldClose()) {
        if (raylib.IsKeyPressed(raylib.KEY_R)) {
            // const state: *anyopaque = plug_pre_reload();
            if (!reload_plugin()) {
                return error.PluginLoadFailed;
            }
            // plug_post_reload(state);
        }

        plug_update();
    }
}

fn reload_plugin() bool {
    if (!unload_plugin()) {
        return false;
    }

    var dyn_lib = std.DynLib.open(libplug_path) catch {
        return false;
    };
    libplug = dyn_lib;

    plug_init = dyn_lib.lookup(@TypeOf(plug_init), "plug_init") orelse return false;
    plug_destroy = dyn_lib.lookup(@TypeOf(plug_destroy), "plug_destroy") orelse return false;
    plug_pre_reload = dyn_lib.lookup(@TypeOf(plug_pre_reload), "plug_pre_reload") orelse return false;
    plug_post_reload = dyn_lib.lookup(@TypeOf(plug_post_reload), "plug_post_reload") orelse return false;
    plug_update = dyn_lib.lookup(@TypeOf(plug_update), "plug_update") orelse return false;

    return true;
}

fn unload_plugin() bool {
    if (libplug) |*lib| {
        lib.close();
        libplug = null;
    }
    return true;
}
