const std = @import("std");
const utils = @import("utils.zig");

fn part1(data: []const u8, allocator: std.mem.Allocator) u64 {
    var lines = utils.lines(data);
    var sum: u64 = 0;
    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        var it = std.mem.tokenizeScalar(u8, line, ':');
        _ = it.next().?;
        var card = std.mem.tokenizeScalar(u8, it.next().?, '|');
        var winning_numbers_raw = std.mem.tokenizeScalar(u8, card.next().?, ' ');
        var numbers_raw = std.mem.tokenizeScalar(u8, card.next().?, ' ');
        var winning_numbers = std.AutoHashMap(u8, void).init(allocator);
        while (winning_numbers_raw.next()) |n_raw| {
            const n = std.fmt.parseInt(u8, n_raw, 10) catch unreachable;
            winning_numbers.put(n, undefined) catch unreachable;
        }
        var count: u6 = 0;
        while (numbers_raw.next()) |n_raw| {
            const n = std.fmt.parseInt(u8, n_raw, 10) catch unreachable;
            if (winning_numbers.contains(n)) {
                count += 1;
            }
        }
        if (count > 0) {
            sum += @as(u64, 1) << (count - 1);
        }
    }
    return sum;
}

pub fn part2(data: []const u8, allocator: std.mem.Allocator) u64 {
    var lines = std.mem.splitBackwardsAny(u8, data, "\n\r");
    var list = std.ArrayList(u64).init(allocator);
    var sum: u64 = 0;
    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        var it = std.mem.tokenizeScalar(u8, line, ':');
        _ = it.next().?;
        var card = std.mem.tokenizeScalar(u8, it.next().?, '|');
        var winning_numbers_raw = std.mem.tokenizeScalar(u8, card.next().?, ' ');
        var numbers_raw = std.mem.tokenizeScalar(u8, card.next().?, ' ');
        var winning_numbers = std.AutoHashMap(u8, void).init(allocator);
        while (winning_numbers_raw.next()) |n_raw| {
            const n = std.fmt.parseInt(u8, n_raw, 10) catch unreachable;
            winning_numbers.put(n, undefined) catch unreachable;
        }
        var count: usize = 0;
        while (numbers_raw.next()) |n_raw| {
            const n = std.fmt.parseInt(u8, n_raw, 10) catch unreachable;
            if (winning_numbers.contains(n)) {
                count += 1;
            }
        }
        var x: u64 = 0;
        for (@max(count, list.items.len) - count..list.items.len) |i| {
            x += list.items[i];
        }
        list.append(x + 1) catch unreachable;
    }
    for (list.items) |x| {
        sum += x;
    }
    return sum;
}

pub fn main() !void {
    const MAX_SIZE: usize = 1 << 15; // 32KB
    var data: [MAX_SIZE]u8 = undefined;
    const size = try utils.read(&data);
    try std.io.getStdOut().writer().print("part1 = {d}\n", .{part1(data[0..size], std.heap.page_allocator)});
    try std.io.getStdOut().writer().print("part2 = {d}\n", .{part2(data[0..size], std.heap.page_allocator)});
}
