const std = @import("std");
const utils = @import("utils.zig");

fn east(c: u8) bool {
    return c == '-' or c == 'F' or c == 'L';
}

fn west(c: u8) bool {
    return c == '-' or c == 'J' or c == '7';
}

fn north(c: u8) bool {
    return c == '|' or c == 'J' or c == 'L';
}

fn south(c: u8) bool {
    return c == '|' or c == '7' or c == 'F';
}

fn corner(c: u8) bool {
    return c == '7' or c == 'F' or c == 'L' or c == 'J';
}

const Direction = enum(u2) {
    South,
    North,
    East,
    West,
};

fn part1(lines: [][]const u8, s_row: usize, s_col: usize) u64 {
    var x: usize = undefined;
    var y: usize = undefined;
    var came_from: Direction = undefined;
    if (s_row >= 1 and south(lines[s_row - 1][s_col])) {
        came_from = Direction.South;
        x = s_row - 1;
        y = s_col;
    } else if (s_row + 1 < lines.len and north(lines[s_row + 1][s_col])) {
        came_from = Direction.North;
        x = s_row + 1;
        y = s_col;
    } else if (s_col >= 1 and south(lines[s_row][s_col - 1])) {
        came_from = Direction.East;
        x = s_row;
        y = s_col - 1;
    } else if (s_col + 1 < lines[s_row].len and north(lines[s_row][s_col + 1])) {
        came_from = Direction.North;
        x = s_row;
        y = s_col + 1;
    }
    var i: u64 = 0;
    while (x != s_row or y != s_col) : (i += 1) {
        if (came_from != Direction.North and north(lines[x][y])) {
            x -= 1;
            came_from = Direction.South;
        } else if (came_from != Direction.South and south(lines[x][y])) {
            x += 1;
            came_from = Direction.North;
        } else if (came_from != Direction.West and west(lines[x][y])) {
            y -= 1;
            came_from = Direction.East;
        } else if (came_from != Direction.East and east(lines[x][y])) {
            y += 1;
            came_from = Direction.West;
        }
    }
    return (i + 1) / 2;
}

const Point = struct {
    x: usize,
    y: usize,
};

fn is_point_in_polygon(p: Point, polygon: []const Point) bool {
    var min_x = polygon[0].x;
    var max_x = polygon[0].x;
    var min_y = polygon[0].y;
    var max_y = polygon[0].y;
    for (polygon[1..]) |q| {
        min_x = @min(q.x, min_x);
        max_x = @max(q.x, max_x);
        min_y = @min(q.y, min_y);
        max_y = @max(q.y, max_y);
    }
    if (p.x < min_x or p.x > max_x or p.y < min_y or p.y > max_y) {
        return false;
    }
    var inside = false;
    {
        const q = polygon[0];
        const r = polygon[polygon.len - 1];
        if ((q.y > p.y) != (r.y > p.y) and q.x > p.x) {
            inside = !inside;
        }
    }
    var it = std.mem.window(Point, polygon, 2, 1);
    while (it.next()) |w| {
        const q = w[1];
        const r = w[0];
        if ((q.y > p.y) != (r.y > p.y) and q.x > p.x) {
            inside = !inside;
        }
    }
    return inside;
}

fn part2(lines: [][]const u8, s_row: usize, s_col: usize) u64 {
    var polygon = std.ArrayList(Point).init(std.heap.page_allocator);
    defer polygon.deinit();
    polygon.append(Point{ .x = s_row, .y = s_col }) catch unreachable;
    var x: usize = undefined;
    var y: usize = undefined;
    var came_from: Direction = undefined;
    if (s_row >= 1 and south(lines[s_row - 1][s_col])) {
        came_from = Direction.South;
        x = s_row - 1;
        y = s_col;
    } else if (s_row + 1 < lines.len and north(lines[s_row + 1][s_col])) {
        came_from = Direction.North;
        x = s_row + 1;
        y = s_col;
    } else if (s_col >= 1 and south(lines[s_row][s_col - 1])) {
        came_from = Direction.East;
        x = s_row;
        y = s_col - 1;
    } else if (s_col + 1 < lines[s_row].len and north(lines[s_row][s_col + 1])) {
        came_from = Direction.North;
        x = s_row;
        y = s_col + 1;
    }
    var loop_size: u64 = 0;
    while (x != s_row or y != s_col) : (loop_size += 1) {
        if (corner(lines[x][y])) {
            polygon.append(Point{ .x = x, .y = y }) catch unreachable;
        }
        if (came_from != Direction.North and north(lines[x][y])) {
            x -= 1;
            came_from = Direction.South;
        } else if (came_from != Direction.South and south(lines[x][y])) {
            x += 1;
            came_from = Direction.North;
        } else if (came_from != Direction.West and west(lines[x][y])) {
            y -= 1;
            came_from = Direction.East;
        } else if (came_from != Direction.East and east(lines[x][y])) {
            y += 1;
            came_from = Direction.West;
        }
    }
    var sum: u64 = 0;
    for (lines, 0..) |line, i| {
        for (line, 0..) |_, j| {
            if (is_point_in_polygon(Point{ .x = i, .y = j }, polygon.items)) {
                sum += 1;
            }
        }
    }
    return sum - loop_size / 2;
}

pub fn main() !void {
    const MAX_SIZE: usize = 1 << 15; // 32KB
    var data: [MAX_SIZE]u8 = undefined;
    const size = try utils.read(&data);
    var lines = utils.lines(data[0..size]);
    var list = std.ArrayList([]const u8).init(std.heap.page_allocator);
    defer list.deinit();
    while (lines.next()) |line| {
        if (line.len != 0) {
            try list.append(line);
        }
    }
    var s_row: usize = undefined;
    var s_col: usize = undefined;
    for (list.items, 0..) |line, row| {
        if (std.mem.indexOf(u8, line, "S")) |col| {
            s_row = row;
            s_col = col;
            break;
        }
    }
    try std.io.getStdOut().writer().print("part1 = {d}\n", .{part1(list.items, s_row, s_col)});
    try std.io.getStdOut().writer().print("part2 = {d}\n", .{part2(list.items, s_row, s_col)});
}
