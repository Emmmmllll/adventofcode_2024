const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn main(alloc: Allocator, input: []const u8) !usize {
    var left, var right = try parse_input(alloc, input);
    var amounts = std.AutoHashMapUnmanaged(u32, usize){};
    defer {
        left.deinit(alloc);
        right.deinit(alloc);
        amounts.deinit(alloc);
    }

    var similarity: usize = 0;

    for (left.items) |item| {
        const amount = amounts.get(item) orelse blk: {
            const amt = search_amount(right.items, item);
            try amounts.putNoClobber(alloc, item, amt);
            break :blk amt;
        };
        similarity += item * amount;
    }

    return similarity;
}

fn search_amount(list: []const u32, target: u32) usize {
    var count: usize = 0;
    for (list) |item| {
        if (item == target) count += 1;
    }
    return count;
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
