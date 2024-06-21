const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    const build_plugin = b.option(bool, "build_plugin", "Only build the plugin") orelse false;

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // --------------------
    // Library build
    // --------------------

    // Library build
    const libplug = b.addSharedLibrary(.{
        .name = "plug",
        .root_source_file = b.path("src/plug.zig"),
        .target = target,
        .optimize = optimize,
    });
    libplug.addIncludePath(.{ .cwd_relative = "raylib/include/" });
    libplug.addLibraryPath(.{ .cwd_relative = "raylib/lib/" });
    libplug.linkSystemLibrary("raylib");
    libplug.linkLibC();
    b.installArtifact(libplug);

    // --------------------
    // Executable build
    // --------------------
    if (!build_plugin) {
        // Executable build
        const exe = b.addExecutable(.{
            .name = "main",
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        });
        exe.addIncludePath(.{ .cwd_relative = "raylib/include/" });
        exe.addLibraryPath(.{ .cwd_relative = "raylib/lib/" });
        exe.linkSystemLibrary("raylib");
        exe.linkLibC();
        b.installArtifact(exe);

        // Build the executable if it is enabled
        const build_exe_cmd = b.addInstallArtifact(exe, .{});
        build_exe_cmd.step.dependOn(b.getInstallStep());
        const build_exe_step = b.step("build_main", "Build the executable");
        build_exe_step.dependOn(&build_exe_cmd.step);

        // Run command
        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }
        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);
    }
}
