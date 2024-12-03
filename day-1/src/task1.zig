const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn main(alloc: Allocator, input: []const u8) !usize {
    var left, var right = try parse_input(alloc, input);
    defer {
        left.deinit(alloc);
        right.deinit(alloc);
    }
    std.mem.sort(u32, left.items, {}, std.sort.asc(u32));
    std.mem.sort(u32, right.items, {}, std.sort.asc(u32));

    var sum: usize = 0;
    for (left.items, right.items) |left_num, right_num| {
        if (left_num > right_num) {
            sum += left_num - right_num;
        } else {
            sum += right_num - left_num;
        }
    }

    return sum;
}

fn parse_input(alloc: Allocator, full_input: []const u8) !struct { std.ArrayListUnmanaged(u32), std.ArrayListUnmanaged(u32) } {
    var left_list = std.ArrayListUnmanaged(u32){};
    var right_list = std.ArrayListUnmanaged(u32){};
    errdefer {
        left_list.deinit(alloc);
        right_list.deinit(alloc);
    }

    var input = full_input;
    var idx: usize = 0;
    var is_left: bool = true;
    var has_switched: bool = false;

    while (input.len > idx) : (idx += 1) {
        if (std.ascii.isDigit(input[idx])) {
            if (has_switched) {
                input = input[idx..];
                idx = 0;
            }
            has_switched = false;
            continue;
        }

        if (has_switched) continue;

        const number = std.fmt.parseInt(u32, input[0..idx], 10) catch |e| {
            std.log.err("({}) parsing '{s}' at [{}]", .{ e, input[0..idx], right_list.items.len });
            return e;
        };

        if (is_left) {
            try left_list.append(alloc, number);
        } else {
            try right_list.append(alloc, number);
        }
        is_left = !is_left;
        has_switched = true;
    }

    if (!has_switched) {
        const number = try std.fmt.parseInt(u32, input[0..idx], 10);

        if (is_left) {
            try left_list.append(alloc, number);
        } else {
            try right_list.append(alloc, number);
        }
    }

    std.debug.assert(left_list.items.len == right_list.items.len);
    return .{ left_list, right_list };
}
