const std = @import("std");
const utils = @import("utils.zig");

fn part1(lines: std.ArrayList([]const u8)) u64 {
    var sum: u64 = 0;
    for (lines.items, 0..) |line, i| {
        var start_opt: ?usize = null;
        for (line, 0..) |c, j| {
            if (start_opt == null) {
                if (utils.is_digit(c)) {
                    start_opt = j;
                }
            } else {
                const start = start_opt.?;
                if (!utils.is_digit(c)) {
                    const number_raw = line[start..j];
                    a: for (lines.items[@max(1, i) - 1 .. @min(lines.items.len, i + 2)]) |k| {
                        for (k[@max(1, start) - 1 .. j + 1]) |l| {
                            if (l != '.' and !utils.is_digit(l)) {
                                const number = std.fmt.parseInt(u64, number_raw, 10) catch unreachable;
                                sum += number;
                                break :a;
                            }
                        }
                    }
                    start_opt = null;
                }
            }
        }
        if (start_opt != null) {
            const start = start_opt.?;
            const number_raw = line[start..];
            a: for (lines.items[@max(1, i) - 1 .. @min(lines.items.len, i + 2)]) |k| {
                for (k[@max(1, start) - 1 .. k.len]) |l| {
                    if (l != '.' and !utils.is_digit(l)) {
                        const number = std.fmt.parseInt(u64, number_raw, 10) catch unreachable;
                        sum += number;
                        break :a;
                    }
                }
            }
        }
    }
    return sum;
}

fn find_start(line: []const u8, index: usize) usize {
    var start = index;
    while (start > 0 and utils.is_digit(line[start - 1])) {
        start -= 1;
    }
    return start;
}

fn find_end(line: []const u8, index: usize) usize {
    var end = index + 1;
    while (end < line.len and utils.is_digit(line[end])) {
        end += 1;
    }
    return end;
}

fn part2(lines: std.ArrayList([]const u8)) u64 {
    var sum: u64 = 0;
    for (lines.items, 0..) |line, i| {
        var pos: usize = 0;
        while (std.mem.indexOfPos(u8, line, pos, "*")) |j| {
            pos = j + 1;
            var topleft = false;
            var topright = false;
            var top = false;
            var bottomleft = false;
            var bottomright = false;
            var bottom = false;
            const left = j > 0 and utils.is_digit(line[j - 1]);
            const right = j + 1 < line.len and utils.is_digit(line[j + 1]);
            if (i > 0) {
                const prevline = lines.items[i - 1];
                if (utils.is_digit(prevline[j])) {
                    top = true;
                } else {
                    topleft = j > 0 and utils.is_digit(prevline[j - 1]);
                    topright = j + 1 < line.len and utils.is_digit(prevline[j + 1]);
                }
            }
            if (i + 1 < lines.items.len) {
                const nextline = lines.items[i + 1];
                if (utils.is_digit(nextline[j])) {
                    bottom = true;
                } else {
                    bottomleft = j > 0 and utils.is_digit(nextline[j - 1]);
                    bottomright = j + 1 < line.len and utils.is_digit(nextline[j + 1]);
                }
            }
            var count: u8 = 0;
            for ([_]bool{ topleft, top, topright, bottomleft, bottom, bottomright, left, right }) |b| {
                if (b) {
                    count += 1;
                }
            }
            if (count != 2) {
                continue;
            }

            var prod: u64 = 1;
            if (topleft) {
                const prevline = lines.items[i - 1];
                const start = find_start(prevline, j);
                const number = std.fmt.parseInt(u64, prevline[start..j], 10) catch unreachable;
                prod *= number;
            }
            if (topright) {
                const prevline = lines.items[i - 1];
                const end = find_end(prevline, j);
                const number = std.fmt.parseInt(u64, prevline[j + 1 .. end], 10) catch unreachable;
                prod *= number;
            }
            if (top) {
                const prevline = lines.items[i - 1];
                const start = find_start(prevline, j);
                const end = find_end(prevline, j);
                const number = std.fmt.parseInt(u64, prevline[start..end], 10) catch unreachable;
                prod *= number;
            }
            if (bottomleft) {
                const nextline = lines.items[i + 1];
                const start = find_start(nextline, j);
                const number = std.fmt.parseInt(u64, nextline[start..j], 10) catch unreachable;
                prod *= number;
            }
            if (bottomright) {
                const nextline = lines.items[i + 1];
                const end = find_end(nextline, j);
                const number = std.fmt.parseInt(u64, nextline[j + 1 .. end], 10) catch unreachable;
                prod *= number;
            }
            if (bottom) {
                const nextline = lines.items[i + 1];
                const start = find_start(nextline, j);
                const end = find_end(nextline, j);
                const number = std.fmt.parseInt(u64, nextline[start..end], 10) catch unreachable;
                prod *= number;
            }
            if (left) {
                const start = find_start(line, j);
                const number = std.fmt.parseInt(u64, line[start..j], 10) catch unreachable;
                prod *= number;
            }
            if (right) {
                const end = find_end(line, j);
                const number = std.fmt.parseInt(u64, line[j + 1 .. end], 10) catch unreachable;
                prod *= number;
            }
            sum += prod;
        }
    }

    return sum;
}

pub fn main() !void {
    const MAX_SIZE: usize = 1 << 15; // 32KB
    var data: [MAX_SIZE]u8 = undefined;
    const size = try utils.read(&data);
    var it = utils.lines(data[0..size]);
    var lines = std.ArrayList([]const u8).init(std.heap.page_allocator);
    defer lines.deinit();
    while (it.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        try lines.append(line);
    }
    try std.io.getStdOut().writer().print("part1 = {d}\n", .{part1(lines)});
    try std.io.getStdOut().writer().print("part2 = {d}\n", .{part2(lines)});
}
