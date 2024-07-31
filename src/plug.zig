const std = @import("std");

const raylib = @cImport({
    @cInclude("raylib.h");
});

const Plug = struct {
    background: raylib.Color,
};

var p: *Plug = undefined;

export fn plug_init() void {
    p = std.heap.c_allocator.create(Plug) catch @panic("Memory allocation failed");
    p.background = raylib.RED;
    raylib.TraceLog(raylib.LOG_INFO, "PLUGIN: Initialized plugin");
}

export fn plug_destroy() void {
    raylib.TraceLog(raylib.LOG_INFO, "PLUGIN: Uninitialized plugin");
}

export fn plug_pre_reload() *anyopaque {
    return @ptrCast(p);
}

export fn plug_post_reload(state: *anyopaque) void {
    p = @ptrCast(state);
}

export fn plug_update() void {
    raylib.BeginDrawing();
    raylib.ClearBackground(p.background);

    // raylib.DrawText("Hello, World!", 100, 100, 20, raylib.WHITE);
    // raylib.DrawText("This is the Hot Reloading plugin working", 100, 150, 15, raylib.WHITE);

    raylib.EndDrawing();
}
