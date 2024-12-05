const std = @import("std");
const Allocator = std.mem.Allocator;

var WIDTH: usize = undefined;
var HEIGHT: usize = undefined;

pub fn main(alloc: Allocator, input: []const u8) !usize {
    _ = alloc;
    WIDTH, HEIGHT = dimensions(input);

    var count: usize = 0;

    for (0..HEIGHT) |y| {
        for (0..WIDTH) |x| {
            if (check(input, .{ @intCast(x), @intCast(y) })) count += 1;
        }
    }
    return count;
}

fn check(input: []const u8, pos: Pos) bool {
    const diagonals = [_][2]Pos{ .{ UP + LEFT, DOWN + RIGHT }, .{ UP + RIGHT, DOWN + LEFT } };
    if (input[pos_idx(pos) orelse return false] != 'A') return false;

    for (&diagonals) |diag| {
        var was_m = false;

        for (&diag) |offset| {
            const idx = pos_idx(pos + offset) orelse return false;
            switch (input[idx]) {
                'M' => {
                    if (was_m) return false;
                    was_m = true;
                },
                'S' => {},
                else => return false,
            }
        }
        if (!was_m) return false;
    }
    return true;
}

fn dimensions(input: []const u8) struct { usize, usize } {
    const width = std.mem.indexOfScalar(u8, input, '\n') orelse unreachable;
    const height = ((input.len - 1) / (width + 1) + 1);
    return .{ width, height };
}

const Pos = @Vector(2, isize);

const UP: Pos = .{ 0, -1 };
const DOWN: Pos = .{ 0, 1 };
const LEFT: Pos = .{ -1, 0 };
const RIGHT: Pos = .{ 1, 0 };

fn pos_idx(self: Pos) ?usize {
    const x, const y = self;
    if (x < 0 or y < 0) return null;
    if (x >= WIDTH or y >= HEIGHT) return null;
    const ux: usize = @intCast(x);
    const uy: usize = @intCast(y);
    return ux + uy * (WIDTH + 1);
}
