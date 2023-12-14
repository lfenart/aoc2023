const std = @import("std");
const utils = @import("utils.zig");

const Item = struct {
    source: u64,
    destination: u64,
    range: u64,
};

fn part1(seeds: []u64, list_list: std.ArrayList(std.ArrayList(Item))) u64 {
    var lowest: u64 = std.math.maxInt(u64);
    for (seeds) |seed| {
        var x = seed;
        for (list_list.items) |l| {
            for (l.items) |item| {
                if (item.source <= x and x < item.source + item.range) {
                    x = x + item.destination - item.source;
                    break;
                }
            }
        }
        lowest = @min(lowest, x);
    }
    return lowest;
}

fn part2(seeds: []u64, list_list: std.ArrayList(std.ArrayList(Item))) u64 {
    var lowest: u64 = std.math.maxInt(u64);
    var pairs = std.mem.window(u64, seeds, 2, 2);
    while (pairs.next()) |pair| {
        for (pair[0]..pair[0] + pair[1]) |seed| {
            var x = seed;
            for (list_list.items) |l| {
                for (l.items) |item| {
                    if (item.source <= x and x < item.source + item.range) {
                        x = x + item.destination - item.source;
                        break;
                    }
                }
            }
            lowest = @min(lowest, x);
        }
    }
    return lowest;
}

pub fn main() !void {
    const MAX_SIZE: usize = 1 << 15; // 32KB
    var data: [MAX_SIZE]u8 = undefined;
    const size = try utils.read(&data);
    var lines = utils.lines(data[0..size]);
    var seeds = std.ArrayList(u64).init(std.heap.page_allocator);
    {
        var it = std.mem.tokenizeScalar(u8, lines.next().?[7..], ' ');
        while (it.next()) |seed| {
            seeds.append(std.fmt.parseInt(u64, seed, 10) catch unreachable) catch unreachable;
        }
    }
    var list = std.ArrayList(Item).init(std.heap.page_allocator);
    var list_list = std.ArrayList(std.ArrayList(Item)).init(std.heap.page_allocator);
    defer {
        for (list_list.items) |l| {
            l.deinit();
        }
        list_list.deinit();
    }
    _ = lines.next().?;
    _ = lines.next().?;
    while (lines.next()) |line| {
        if (line.len == 0) {
            list_list.append(list) catch unreachable;
            list = std.ArrayList(Item).init(std.heap.page_allocator);
            _ = lines.next();
        } else {
            var it = std.mem.tokenizeScalar(u8, line, ' ');
            const destination = std.fmt.parseInt(u64, it.next().?, 10) catch unreachable;
            const source = std.fmt.parseInt(u64, it.next().?, 10) catch unreachable;
            const range = std.fmt.parseInt(u64, it.next().?, 10) catch unreachable;
            list.append(Item{
                .destination = destination,
                .source = source,
                .range = range,
            }) catch unreachable;
        }
    }
    try std.io.getStdOut().writer().print("part1 = {d}\n", .{part1(seeds.items, list_list)});
    try std.io.getStdOut().writer().print("part2 = {d}\n", .{part2(seeds.items, list_list)});
}
