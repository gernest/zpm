const package_dir = blk: {
    break :blk "vendor";
};
pub fn import(path: []const u8) type {
    return struct {
        const pkg = @import(package_dir ++ "/" ++ path);
    };
}

test "bang" {
    const say = import("semver");
    say.pkg.again();
}
