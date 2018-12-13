const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();
    const exe = b.addExecutable("zpm", "src/main.zig");
    exe.addPackagePath("clap", "lib/clap/src/index.zig");
    exe.addPackagePath("semver", "lib/semver/src/main.zig");
    exe.setBuildMode(mode);
    var main_tests = b.addTest("src/main.zig");
    main_tests.addPackagePath("semver", "lib/semver/src/main.zig");
    main_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run app tests");
    test_step.dependOn(&main_tests.step);
    b.default_step.dependOn(&exe.step);
    b.installArtifact(exe);
}
