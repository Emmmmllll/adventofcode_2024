const std = @import("std");
const Allocator = std.mem.Allocator;

fn read_file(name: []const u8, alloc: Allocator) ![]u8 {
    const file = try std.fs.cwd().openFile(name, .{});
    defer file.close();
    return file.readToEndAlloc(alloc, std.math.maxInt(usize));
}

pub fn main() !void {
    var gpa_instance = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa_instance.deinit();
    const alloc = gpa_instance.allocator();

    if (read_file("input.txt", alloc)) |input| {
        defer alloc.free(input);

        std.log.info("[Task 1]", .{});
        std.log.info("The answer is {}", .{
            try @import("task1.zig").main(alloc, input),
        });

        std.log.info("[Task 2]", .{});
        std.log.info("The answer is {}", .{
            try @import("task2.zig").main(alloc, input),
        });
    } else |_| {
        std.log.warn("File 'input.txt' not found!", .{});
    }
}
