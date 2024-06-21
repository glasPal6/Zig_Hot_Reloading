const std = @import("std");

const libplug_path = "zig-out/lib/libplug.so";
var libplug: ?std.DynLib = null;

pub var plug_init: *const fn () void = undefined;
pub var plug_destroy: *const fn () void = undefined;
pub var plug_pre_reload: *const fn () *anyopaque = undefined;
pub var plug_post_reload: *const fn (*anyopaque) void = undefined;
pub var plug_update: *const fn () void = undefined;

pub fn reload_plugin() bool {
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

pub fn unload_plugin() bool {
    if (libplug) |*lib| {
        lib.close();
        libplug = null;
    }
    return true;
}
