const std = @import("std");
const Allocator = std.mem.Allocator;

const MulInstruction = struct {
    lhs: u32,
    rhs: u32,
};

pub fn main(alloc: Allocator, input: []const u8) !usize {
    var instructions = try parse(alloc, input);
    defer instructions.deinit(alloc);

    var sum: u32 = 0;

    for (instructions.items) |inst| {
        sum += inst.lhs * inst.rhs;
    }

    return sum;
}

fn parse(alloc: Allocator, input: []const u8) !std.ArrayListUnmanaged(MulInstruction) {
    const MUL_EXPR = "mul(";
    const SEP = ',';
    const END = ')';

    var remaining = input;
    var instructions = std.ArrayListUnmanaged(MulInstruction){};
    errdefer {
        instructions.deinit(alloc);
    }

    while (true) {
        const start_idx = std.mem.indexOf(u8, remaining, MUL_EXPR) orelse break;
        remaining = remaining[MUL_EXPR.len + start_idx ..];

        // std.log.debug("found 'mul('", .{});

        const sep_idx, const lhs = parse_num(remaining) orelse continue;
        remaining = remaining[sep_idx..];
        if (remaining[0] != SEP) continue;
        remaining = remaining[1..];
        // std.log.debug("found lhs: '{}'", .{lhs});

        const brak_idx, const rhs = parse_num(remaining) orelse continue;
        remaining = remaining[brak_idx..];
        if (remaining[0] != END) continue;
        remaining = remaining[1..];
        // std.log.debug("found rhs: '{}'", .{lhs});

        try instructions.append(alloc, .{ .lhs = lhs, .rhs = rhs });
    }

    return instructions;
}

fn parse_num(input: []const u8) ?struct { usize, u32 } {
    const MAX_NUM_DIGIT = 3;
    var i: usize = 0;
    while (i < MAX_NUM_DIGIT) : (i += 1) {
        if (std.ascii.isDigit(input[i])) continue;
        // no number => invalid
        if (i == 0) return null;
        break;
    }
    const num = std.fmt.parseInt(u32, input[0..i], 10) catch unreachable;
    return .{ i, num };
}
