const std = @import("std");
const Allocator = std.mem.Allocator;

const MulInstruction = struct {
    lhs: u32,
    rhs: u32,
};

const Instruction = union(enum) {
    do,
    dont,
    mul: MulInstruction,
};

pub fn main(alloc: Allocator, input: []const u8) !usize {
    var instructions = try parse(alloc, input);
    defer instructions.deinit(alloc);

    var sum: u32 = 0;
    var mul_enabled = true;

    for (instructions.items) |inst| {
        switch (inst) {
            .do => mul_enabled = true,
            .dont => mul_enabled = false,
            .mul => |mul| {
                if (mul_enabled) {
                    sum += mul.lhs * mul.rhs;
                }
            },
        }
    }

    return sum;
}

fn parse(alloc: Allocator, input: []const u8) !std.ArrayListUnmanaged(Instruction) {
    const MUL_EXPR = "mul(";
    const DO_EXPR = "do()";
    const DONT_EXPR = "don't()";

    var remaining = input;
    var instructions = std.ArrayListUnmanaged(Instruction){};
    errdefer {
        instructions.deinit(alloc);
    }

    const MAX = std.math.maxInt(usize);
    var indecies: @Vector(3, usize) = undefined;

    indecies[0] = std.mem.indexOf(u8, remaining, MUL_EXPR) orelse MAX;
    indecies[1] = std.mem.indexOf(u8, remaining, DO_EXPR) orelse MAX;
    indecies[2] = std.mem.indexOf(u8, remaining, DONT_EXPR) orelse MAX;

    while (true) {
        const min = @reduce(.Min, indecies);

        if (min > remaining.len) break;

        indecies -= @splat(min);
        remaining = remaining[min..];

        if (0 == indecies[0]) {
            remaining = remaining[MUL_EXPR.len..];
            indecies -= @Vector(3, usize){ 0, MUL_EXPR.len, MUL_EXPR.len };
            indecies[0] = std.mem.indexOf(u8, remaining, MUL_EXPR) orelse MAX;
            try instructions.append(alloc, .{ .mul = parse_mul_inst(remaining) orelse continue });
        } else if (0 == indecies[1]) {
            remaining = remaining[DO_EXPR.len..];
            indecies -= @Vector(3, usize){ DO_EXPR.len, 0, DO_EXPR.len };
            indecies[1] = std.mem.indexOf(u8, remaining, DO_EXPR) orelse MAX;
            try instructions.append(alloc, .do);
        } else if (0 == indecies[2]) {
            remaining = remaining[DONT_EXPR.len..];
            indecies -= @Vector(3, usize){ DONT_EXPR.len, DONT_EXPR.len, 0 };
            indecies[2] = std.mem.indexOf(u8, remaining, DONT_EXPR) orelse MAX;
            try instructions.append(alloc, .dont);
        } else unreachable;
    }

    return instructions;
}

fn parse_mul_inst(input: []const u8) ?MulInstruction {
    const SEP = ',';
    const END = ')';
    var remaining = input;

    const sep_idx, const lhs = parse_num(remaining) orelse return null;
    remaining = remaining[sep_idx..];
    if (remaining[0] != SEP) return null;
    remaining = remaining[1..];

    const brak_idx, const rhs = parse_num(remaining) orelse return null;
    remaining = remaining[brak_idx..];
    if (remaining[0] != END) return null;
    remaining = remaining[1..];

    return .{ .lhs = lhs, .rhs = rhs };
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
