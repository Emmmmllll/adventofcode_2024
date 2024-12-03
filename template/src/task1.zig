const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn main(alloc: Allocator, input: []const u8) !usize {
    _ = alloc;
    _ = input;
    return 42;
}
