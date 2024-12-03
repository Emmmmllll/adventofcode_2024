const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn main(alloc: Allocator, input: []const u8) !usize {
    var levels, var reports = try parse(alloc, input);
    defer {
        levels.deinit(alloc);
        reports.deinit(alloc);
    }

    var safe_count: usize = 0;

    for (0..reports.items.len) |rep_idx| {
        const level_idx = reports.items[rep_idx];
        const next_level_idx = if (rep_idx + 1 == reports.items.len) levels.items.len else reports.items[rep_idx + 1];
        const report = levels.items[level_idx..next_level_idx];

        if (is_safe(report)) safe_count += 1;
    }

    return safe_count;
}

fn is_safe(report: []const u32) bool {
    std.debug.assert(report.len >= 2);
    // get the starting flavor
    var is_increasing = report[0] < report[1];
    var skipping_bad = false;
    var bad_exists = false;
    var i = 1;

    while (i < report.len) : (i += 1) {
        const cur = report[i];
        const last = report[i - if (skipping_bad) @as(usize, 2) else @as(usize, 1)];
        skipping_bad = false;

        if (is_step_safe(last, cur, is_increasing)) continue;
        // only one bad is tolerated
        if (bad_exists) return false;

        bad_exists = true;
        skipping_bad = true;
    }

    return true;
}

fn is_step_safe(last: u32, cur: u32, is_increasing: bool) bool {
    // must not be equal
    if (cur == last) return false;
    // must stay flavor
    if ((last < cur) != is_increasing) return false;
    // must be in step range
    const diff = if (is_increasing) cur - last else last - cur;
    if (diff > 3) return false;

    return true;
}

///
/// Returns list of Levels and list of reports.
/// List of reports are indexes into list of levels
///
/// One report is a list of levels
fn parse(alloc: Allocator, input: []const u8) !struct { std.ArrayListUnmanaged(u32), std.ArrayListUnmanaged(usize) } {
    var levels = std.ArrayListUnmanaged(u32){};
    var reports = std.ArrayListUnmanaged(usize){};

    errdefer {
        levels.deinit(alloc);
        reports.deinit(alloc);
    }

    var line_iter = std.mem.splitScalar(u8, input, '\n');
    while (line_iter.next()) |line| {
        if (line.len == 0) continue;

        try reports.append(alloc, levels.items.len);

        var level_iter = std.mem.splitScalar(u8, line, ' ');
        while (level_iter.next()) |level| {
            const num_level = try std.fmt.parseInt(u32, level, 10);
            try levels.append(alloc, num_level);
        }
    }
    return .{ levels, reports };
}
