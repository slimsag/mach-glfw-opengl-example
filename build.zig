const std = @import("std");

pub fn build(b: *std.build.Builder) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Add your executable and configure with
    // target and optimize, specify your root file (ex. main.zig)
    const exe = b.addExecutable(.{
        .name = "mach-glfw-opengl-example",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    // Add the mach_glfw dependency, note the name here
    // should match the name in your build.zig.zon
    const glfw_dep = b.dependency("mach_glfw", .{
        .target = target,
        .optimize = optimize,
    });

    // Now we link the resulting library,
    // passing in the artifact from our dependency
    exe.linkLibrary(glfw_dep.artifact("mach-glfw"));

    // Add the module to our package scope
    // Note the name here is the module that
    // you will import (`@import("mach-glfw")`)
    exe.addModule("mach-glfw", glfw_dep.module("mach-glfw"));

    // Use the mach-glfw .link helper here
    // to link the glfw library for us
    try @import("mach_glfw").link(b, exe);

    // Same as above for our gl module,
    // because we copied the gl code into the project
    // we instead just create the module inline
    exe.addModule("gl", b.createModule(.{
        .source_file = .{ .path = "libs/gl41.zig" },
    }));

    // Once all is done, we install our artifact which
    // in this case is our executable
    b.installArtifact(exe);

    // This is basic boilerplate from zig's stock build.zig,
    // We add a run step so we can run `zig build run` to
    // execute our program after building
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Similar to the above but this adds tests
    // and a test step 'zig build test'
    const unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}
