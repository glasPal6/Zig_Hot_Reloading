const raylib = @cImport({
    @cInclude("raylib.h");
});

const Plug = struct {
    background: raylib.Color,
};

var p: *anyopaque = undefined;

export fn plug_init() void {
    const p_plug: *Plug = @ptrCast(p);
    p_plug.background = raylib.RED;

    raylib.TraceLog(raylib.LOG_INFO, "PLUGIN: Initialized plugin");
}

export fn plug_destroy() void {
    // TODO: Destroy plugin
    raylib.TraceLog(raylib.LOG_INFO, "PLUGIN: Uninitialized plugin");
}

export fn plug_pre_reload() *anyopaque {
    return p;
}

export fn plug_post_reload(state: *anyopaque) void {
    p = state;
}

export fn plug_update() void {
    raylib.BeginDrawing();
    defer raylib.EndDrawing();

    raylib.ClearBackground(raylib.RED);

    raylib.DrawText("Hello, World!", 100, 100, 20, raylib.WHITE);
    raylib.DrawText("This is the Hot Reloading plugin working", 100, 150, 15, raylib.WHITE);
}
