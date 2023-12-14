const std = @import("std");
const utils = @import("utils.zig");

fn part1(data: []const u8) u64 {
    var lines = utils.lines(data);
    var sum: u64 = 0;
    while (lines.next()) |line| {
        for (line) |c| {
            if (utils.is_digit(c)) {
                sum += 10 * (c - '0');
                break;
            }
        }
        var i: usize = line.len;
        while (i > 0) {
            i -= 1;
            const c = line[i];
            if (utils.is_digit(c)) {
                sum += c - '0';
                break;
            }
        }
    }
    return sum;
}

fn part2(data: []const u8) u64 {
    var lines = utils.lines(data);
    var sum: u64 = 0;
    const words = [_][]const u8{ "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };
    while (lines.next()) |line| {
        a: for (line, 1..) |c, i| {
            if (utils.is_digit(c)) {
                sum += 10 * (c - '0');
                break;
            }
            for (words, 1..) |word, j| {
                if (word.len > i) {
                    continue;
                }
                if (std.mem.eql(u8, word, line[i - word.len .. i])) {
                    sum += 10 * j;
                    break :a;
                }
            }
        }
        {
            var i = line.len;
            a: while (i > 0) {
                const c = line[i - 1];
                if (utils.is_digit(c)) {
                    sum += c - '0';
                    break;
                }
                for (words, 1..) |word, j| {
                    if (word.len > i) {
                        continue;
                    }
                    if (std.mem.eql(u8, word, line[i - word.len .. i])) {
                        sum += j;
                        break :a;
                    }
                }
                i -= 1;
            }
        }
    }
    return sum;
}

pub fn main() !void {
    const MAX_SIZE: usize = 1 << 15; // 32KB
    var data: [MAX_SIZE]u8 = undefined;
    const size = try utils.read(&data);
    try std.io.getStdOut().writer().print("part1 = {d}\n", .{part1(data[0..size])});
    try std.io.getStdOut().writer().print("part2 = {d}\n", .{part2(data[0..size])});
}
