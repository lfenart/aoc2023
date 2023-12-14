const std = @import("std");
const utils = @import("utils.zig");

fn part1(times: []const u64, distances: []const u64) u64 {
    var prod: u64 = 1;
    for (times, distances) |time, record| {
        var count: u64 = 0;
        for (0..time) |speed| {
            const distance = speed * (time - speed);
            if (distance > record) {
                count += 1;
            }
        }
        prod *= count;
    }
    return prod;
}

fn part2(time: u64, record: u64) u64 {
    var count: u64 = 0;
    for (0..time) |speed| {
        const distance = speed * (time - speed);
        if (distance > record) {
            count += 1;
        }
    }
    return count;
}

pub fn main() !void {
    const MAX_SIZE: usize = 1 << 15; // 32KB
    var data: [MAX_SIZE]u8 = undefined;
    const size = try utils.read(&data);
    var lines = utils.lines(data[0..size]);
    var times = std.ArrayList(u64).init(std.heap.page_allocator);
    var total_time: u64 = 0;
    defer times.deinit();
    {
        var it = std.mem.tokenizeScalar(u8, lines.next().?, ' ');
        _ = it.next().?;
        while (it.next()) |t| {
            const time: u64 = std.fmt.parseInt(u64, t, 10) catch unreachable;
            times.append(time) catch unreachable;
            for (0..t.len) |_| {
                total_time *= 10;
            }
            total_time += time;
        }
    }
    var distances = std.ArrayList(u64).init(std.heap.page_allocator);
    var total_distance: u64 = 0;
    defer distances.deinit();
    {
        var it = std.mem.tokenizeScalar(u8, lines.next().?, ' ');
        _ = it.next().?;
        while (it.next()) |d| {
            const distance: u64 = std.fmt.parseInt(u64, d, 10) catch unreachable;
            distances.append(distance) catch unreachable;
            for (0..d.len) |_| {
                total_distance *= 10;
            }
            total_distance += distance;
        }
    }
    try std.io.getStdOut().writer().print("part1 = {d}\n", .{part1(times.items, distances.items)});
    try std.io.getStdOut().writer().print("part2 = {d}\n", .{part2(total_time, total_distance)});
}
