const std = @import("std");
const Allocator = std.mem.Allocator;

var WIDTH: usize = undefined;
var HEIGHT: usize = undefined;

pub fn main(alloc: Allocator, input: []const u8) !usize {
    _ = alloc;
    WIDTH, HEIGHT = dimensions(input);

    std.log.debug("w: {}, h: {}, l:{}", .{ WIDTH, HEIGHT, input.len });

    const directions = [_]Pos{ UP, UP + LEFT, UP + RIGHT, LEFT, RIGHT, DOWN, DOWN + LEFT, DOWN + RIGHT };

    var count: usize = 0;

    for (0..HEIGHT) |y| {
        for (0..WIDTH) |x| {
            for (&directions) |dir| {
                if (check(input, .{ @intCast(x), @intCast(y) }, dir)) count += 1;
            }
        }
    }
    return count;
}

fn check(input: []const u8, start: Pos, dir: Pos) bool {
    const word = "XMAS";
    var pos = start;

    for (word) |c| {
        const idx = pos_idx(pos) orelse return false;
        if (c != input[idx]) return false;
        pos += dir;
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
