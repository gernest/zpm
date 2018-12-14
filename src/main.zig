const std = @import("std");
const ArenaAllocator = std.heap.ArenaAllocator;
const Allocator = std.mem.Allocator;
const warn = std.debug.warn;
const semver = @import("semver");
const json = @import("zson");

const PackageInfo = struct {
    name: []const u8,
    version: ?[]const u8,
    source: ?Source,

    fn encode(self: PackageInfo, a: *Allocator) !json.Value {
        var m = json.ObjectMap.init(a);
        const name_value = json.Value{ .String = self.name };
        _ = try m.put("name", name_value);
        if (self.version) |v| {
            const version_value = json.Value{ .String = v };
            _ = try m.put("version", version_value);
        }
        if (self.source) |src| {
            const src_value = try src.encode(a);
            _ = try m.put("source", src_value);
        }
        return json.Value{ .Object = m };
    }
};

const Source = union(enum) {
    git: []const u8,
    file: []const u8,

    fn encode(self: Source, a: *Allocator) !json.Value {
        var m = json.ObjectMap.init(a);
        switch (self) {
            Source.git => |v| {
                const value = json.Value{ .String = v };
                _ = try m.put("git", value);
            },
            Source.file => |v| {
                const value = json.Value{ .String = v };
                _ = try m.put("file", value);
            },
            else => unreachable,
        }
        return json.Value{ .Object = m };
    }
};

const Version = struct {
    name: []const u8,
    version: ?[]const u8,

    pub fn check(self: *const Version) bool {
        return semver.isValid(self.version);
    }

    fn encode(self: Version, a: *Allocator) json.Value {
        if (self.version) |v| {
            return json.Value{ .String = self.name ++ "@" ++ v };
        }
        return json.Value{ .String = self.name };
    }
};

test "Version" {
    const v = Version{ .name = "zpm", .version = "v0.1.0" };
    var a = warn("check {}\n", v.check());
}

test "encode" {
    var a = ArenaAllocator.init(std.debug.global_allocator);
    defer a.deinit();

    var buf = &try std.Buffer.init(std.debug.global_allocator, "");
    defer buf.deinit();

    var buf_stream = std.io.BufferOutStream.init(buf);
    const p = PackageInfo{
        .name = "zpm",
        .version = "v0.1.0",
        .source = Source{ .git = "github.com/gerenst/zpm" },
    };

    const value = try p.encode(&a.allocator);
    try value.dump(&buf_stream.stream);
    warn("{}\n", buf.toSlice());
}

pub fn main() void {}
