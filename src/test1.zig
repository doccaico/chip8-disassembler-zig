const std = @import("std");
const fmt = std.fmt;
const mem = std.mem;
const print = std.debug.print;
const assert = std.debug.assert;
const expect = std.testing.expect;

fn f(stdout: anytype) !void {
    try stdout.writeAll("Hi\n");
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    f(stdout);
    print("Hi\n", .{});
}
// zig test filename.zig
test "How" {
    // const buffer: [100]u8 = undefined;
    // const bw = std.io.bufferedWriter(std.io.getStdOut().writer());
    // const writer = bw.writer();
    //
    // try f(writer);

    // var buffer: [1024]u8 = undefined;
    // const read = std.io.getStdIn().reader().read(&buffer) catch @panic("error reading");

    // var buf: [0x100]u8 = undefined;
    // var fbs = std.io.fixedBufferStream(&buf);

    var a = std.ArrayList(u8).init(std.testing.allocator);
    defer a.deinit();

    try f(a.writer());

    const actual = a.items;
    const expected = "Hi\n";
    try std.testing.expectEqualStrings(expected, actual);
}
//  const stdout = std.io.getStdOut().writer();
//  const message: []const u8 = "Hello, World!";
//  try stdout.print("{s}\n", .{message});
