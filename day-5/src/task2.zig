const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn main(alloc: Allocator, input: []const u8) !usize {
    var rules, var pages, var manuals = try parse(alloc, input);
    defer {
        rules.deinit(alloc);
        pages.deinit(alloc);
        manuals.deinit(alloc);
    }

    try manuals.append(alloc, pages.items.len);

    var sum: Num = 0;

    for (0..manuals.items.len - 1) |i| {
        const manual_idx = manuals.items[i];
        const manual_end = manuals.items[i + 1];
        const manual = pages.items[manual_idx..manual_end];

        for (rules.items) |rule| {
            const first_idx = std.mem.indexOfScalar(Num, manual, rule.first) orelse continue;
            const second_idx = std.mem.indexOfScalar(Num, manual, rule.second) orelse continue;
            if (first_idx > second_idx) break;
        } else {
            continue;
        }

        std.mem.sort(Num, manual, rules.items, struct {
            fn lessThan(ctx: []Rule, lhs: Num, rhs: Num) bool {
                for (ctx) |rule| {
                    if (rule.first == lhs and rule.second == rhs) return true;
                }
                return false;
            }
        }.lessThan);

        const middle_idx = (manual.len - 1) / 2;
        sum += manual[middle_idx];
    }

    return sum;
}

const Num = u32;
const Idx = usize;
const Rule = struct {
    first: Num,
    second: Num,
};

fn parse(alloc: Allocator, input: []const u8) !struct { std.ArrayListUnmanaged(Rule), std.ArrayListUnmanaged(Num), std.ArrayListUnmanaged(Idx) } {
    var rules = std.ArrayListUnmanaged(Rule){};
    var pages = std.ArrayListUnmanaged(Num){};
    var manual_starts = std.ArrayListUnmanaged(Idx){};

    errdefer {
        rules.deinit(alloc);
        pages.deinit(alloc);
        manual_starts.deinit(alloc);
    }

    var lines = std.mem.splitScalar(u8, input, '\n');

    while (lines.next()) |line| {
        if (line.len == 0) break;

        var rule_parts = std.mem.splitScalar(u8, line, '|');
        const first = try std.fmt.parseInt(Num, rule_parts.next() orelse break, 10);
        const second = try std.fmt.parseInt(Num, rule_parts.next() orelse break, 10);

        try rules.append(alloc, .{
            .first = first,
            .second = second,
        });
    }

    while (lines.next()) |line| {
        if (line.len == 0) break;

        var numbers = std.mem.splitScalar(u8, line, ',');

        try manual_starts.append(alloc, pages.items.len);

        while (numbers.next()) |number_text| {
            const num = try std.fmt.parseInt(Num, number_text, 10);
            try pages.append(alloc, num);
        }
    }

    return .{
        rules, pages, manual_starts,
    };
}
