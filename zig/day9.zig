const std = @import("std");
const utils = @import("utils.zig");

fn part1(lines: []std.ArrayList(i64)) i64 {
    var sum: i64 = 0;
    for (lines) |line| {
        var i = line.items.len;
        while (true) {
            i -= 1;
            var end = true;
            for (0..i) |j| {
                const c = line.items[j + 1] - line.items[j];
                line.items[j] = c;
                if (c != 0) {
                    end = false;
                }
            }
            if (end) {
                for (line.items[i..]) |v| {
                    sum += v;
                }
                break;
            }
        }
    }

    return sum;
}

fn part2(lines: []std.ArrayList(i64)) i64 {
    var sum: i64 = 0;
    for (lines) |line| {
        var i: usize = line.items.len;
        while (true) : (i -= 1) {
            var end = true;
            for (1..i) |j| {
                const c = line.items[line.items.len - j] - line.items[line.items.len - j - 1];
                line.items[line.items.len - j] = c;
                if (c != 0) {
                    end = false;
                }
            }
            if (end) {
                var sign: i64 = 1;
                for (line.items[0 .. line.items.len - i + 1]) |v| {
                    sum += sign * v;
                    sign = -sign;
                }
                break;
            }
        }
    }

    return sum;
}

pub fn main() !void {
    const MAX_SIZE: usize = 1 << 15; // 32KB
    var data: [MAX_SIZE]u8 = undefined;
    const size = try utils.read(&data);
    var lines = utils.lines(data[0..size]);
    var list = std.ArrayList(std.ArrayList(i64)).init(std.heap.page_allocator);
    defer {
        for (list.items) |i| {
            i.deinit();
        }
        list.deinit();
    }
    var list2 = std.ArrayList(std.ArrayList(i64)).init(std.heap.page_allocator);
    defer {
        for (list2.items) |i| {
            i.deinit();
        }
        list2.deinit();
    }
    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        var numbers = std.ArrayList(i64).init(std.heap.page_allocator);
        var numbers2 = std.ArrayList(i64).init(std.heap.page_allocator);
        var it = std.mem.splitScalar(u8, line, ' ');
        while (it.next()) |n| {
            try numbers.append(try std.fmt.parseInt(i64, n, 10));
            try numbers2.append(try std.fmt.parseInt(i64, n, 10));
        }
        try list.append(numbers);
        try list2.append(numbers2);
    }
    try std.io.getStdOut().writer().print("part1 = {d}\n", .{part1(list.items)});
    try std.io.getStdOut().writer().print("part2 = {d}\n", .{part2(list2.items)});
}
