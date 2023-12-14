const std = @import("std");
const utils = @import("utils.zig");

const Line = struct {
    data: []const u8,
    groups: []const usize,
};

const K = struct {
    index: usize,
    group_index: usize,
};

fn search(line: Line, index: usize, group_index: usize, map: *std.AutoHashMap(K, u64)) u64 {
    if (group_index >= line.groups.len) {
        if (index == line.data.len and line.data[index - 1] == '#') {
            return 0;
        }
        if (index >= line.data.len) {
            return 1;
        }
        if (index > 0 and line.data[index - 1] == '#') {
            return 0;
        }
        if (std.mem.indexOf(u8, line.data[index..], "#")) |_| {
            return 0;
        }
        return 1;
    }
    if (index >= line.data.len) {
        return 0;
    }
    const group = line.groups[group_index];
    var sum: u64 = 0;
    for (index..line.data.len) |i| {
        const x = line.data[i..];
        if (x.len < group) {
            break;
        }
        if (i > 0 and line.data[i - 1] == '#') {
            break;
        }
        if (std.mem.indexOf(u8, x[0..group], ".")) |_| {
            continue;
        }
        if (group < x.len and x[group] == '#') {
            continue;
        }
        if (map.get(K{ .index = i, .group_index = group_index })) |v| {
            sum += v;
        } else {
            const toto = search(line, i + 1 + group, group_index + 1, map);
            map.put(K{ .index = i, .group_index = group_index }, toto) catch unreachable;
            sum += toto;
        }
    }
    return sum;
}

fn part1(lines: []const Line) u64 {
    var sum: u64 = 0;
    for (lines) |line| {
        var map = std.AutoHashMap(K, u64).init(std.heap.page_allocator);
        sum += search(line, 0, 0, &map);
    }
    return sum;
}

fn part2(lines: []const Line) u64 {
    var sum: u64 = 0;
    for (lines, 0..) |line, i| {
        _ = i;

        var data = std.ArrayList(u8).init(std.heap.page_allocator);
        var groups = std.ArrayList(usize).init(std.heap.page_allocator);
        for (0..5) |_| {
            for (line.data) |x| {
                data.append(x) catch unreachable;
            }
            for (line.groups) |group| {
                groups.append(group) catch unreachable;
            }
            data.append('?') catch unreachable;
        }
        data.shrinkRetainingCapacity(data.items.len - 1);
        const x = Line{ .data = data.items, .groups = groups.items };
        var map = std.AutoHashMap(K, u64).init(std.heap.page_allocator);
        sum += search(x, 0, 0, &map);
    }
    return sum;
}

pub fn main() !void {
    const MAX_SIZE: usize = 1 << 15; // 32KB
    var data: [MAX_SIZE]u8 = undefined;
    const size = try utils.read(&data);
    var lines = utils.lines(data[0..size]);
    var list = std.ArrayList(Line).init(std.heap.page_allocator);
    while (lines.next()) |line| {
        if (std.mem.indexOf(u8, line, " ")) |index| {
            var it = std.mem.splitScalar(u8, line[index + 1 ..], ',');
            var groups = std.ArrayList(usize).init(std.heap.page_allocator);
            while (it.next()) |s| {
                const n = try std.fmt.parseUnsigned(usize, s, 10);
                try groups.append(n);
            }
            try list.append(Line{ .data = line[0..index], .groups = groups.items });
        }
    }
    defer list.deinit();
    try std.io.getStdOut().writer().print("part2 = {d}\n", .{part1(list.items)});
    try std.io.getStdOut().writer().print("part2 = {d}\n", .{part2(list.items)});
}
