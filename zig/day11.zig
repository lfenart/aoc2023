const std = @import("std");
const utils = @import("utils.zig");

const Point = struct {
    x: usize,
    y: usize,
};

fn part1(points: []const Point, rows: usize, cols: usize) u64 {
    var empty_lines = std.ArrayList(bool).init(std.heap.page_allocator);
    defer empty_lines.deinit();
    for (0..rows) |_| {
        empty_lines.append(true) catch unreachable;
    }
    var empty_cols = std.ArrayList(bool).init(std.heap.page_allocator);
    defer empty_cols.deinit();
    for (0..cols) |_| {
        empty_cols.append(true) catch unreachable;
    }
    for (points) |point| {
        empty_lines.items[point.x] = false;
        empty_cols.items[point.y] = false;
    }
    var dist: u64 = 0;
    for (points[1..], 1..) |start, i| {
        for (points[0..i]) |end| {
            const min_x = @min(start.x, end.x);
            const max_x = @max(start.x, end.x);
            dist += max_x - min_x;
            for (min_x..max_x) |x| {
                if (empty_lines.items[x]) {
                    dist += 1;
                }
            }
            const min_y = @min(start.y, end.y);
            const max_y = @max(start.y, end.y);
            dist += max_y - min_y;
            for (min_y..max_y) |y| {
                if (empty_cols.items[y]) {
                    dist += 1;
                }
            }
        }
    }
    return dist;
}

fn part2(points: []const Point, rows: usize, cols: usize) u64 {
    var empty_lines = std.ArrayList(bool).init(std.heap.page_allocator);
    defer empty_lines.deinit();
    for (0..rows) |_| {
        empty_lines.append(true) catch unreachable;
    }
    var empty_cols = std.ArrayList(bool).init(std.heap.page_allocator);
    defer empty_cols.deinit();
    for (0..cols) |_| {
        empty_cols.append(true) catch unreachable;
    }
    for (points) |point| {
        empty_lines.items[point.x] = false;
        empty_cols.items[point.y] = false;
    }
    var dist: u64 = 0;
    for (points[1..], 1..) |start, i| {
        for (points[0..i]) |end| {
            const min_x = @min(start.x, end.x);
            const max_x = @max(start.x, end.x);
            dist += max_x - min_x;
            for (min_x..max_x) |x| {
                if (empty_lines.items[x]) {
                    dist += 999999;
                }
            }
            const min_y = @min(start.y, end.y);
            const max_y = @max(start.y, end.y);
            dist += max_y - min_y;
            for (min_y..max_y) |y| {
                if (empty_cols.items[y]) {
                    dist += 999999;
                }
            }
        }
    }
    return dist;
}

pub fn main() !void {
    const MAX_SIZE: usize = 1 << 15; // 32KB
    var data: [MAX_SIZE]u8 = undefined;
    const size = try utils.read(&data);
    var lines = utils.lines(data[0..size]);
    var list = std.ArrayList(Point).init(std.heap.page_allocator);
    defer list.deinit();
    var i: usize = 0;
    var j: usize = undefined;
    while (lines.next()) |line| : (i += 1) {
        if (line.len != 0) {
            j = line.len;
            var index: usize = 0;
            while (std.mem.indexOf(u8, line[index..], "#")) |col| {
                index += col + 1;
                try list.append(Point{ .x = i, .y = index - 1 });
            }
        }
    }
    try std.io.getStdOut().writer().print("part1 = {d}\n", .{part1(list.items, i, j)});
    try std.io.getStdOut().writer().print("part1 = {d}\n", .{part2(list.items, i, j)});
}
