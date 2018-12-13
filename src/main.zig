const std = @import("std");
const warn = std.debug.warn;
const semver = @import("semver");

const Package = struct {
    name: ?[]const u8,
    version: ?[]const u8,
    versions: ?[]const []const u8,
    main: bool,
    directory: ?[]const u8,
    package_file: ?[]const u8,
    zig_version: ?[]const u8,
};

const Version = struct {
    name: []const u8,
    version: []const u8,

    pub fn check(self: *const Version) bool {
        return semver.isValid(self.version);
    }
};

test "Version" {
    const v = Version{ .name = "zpm", .version = "v0.1.0" };
    warn("check {}\n", v.check());
}

pub fn main() void {}
