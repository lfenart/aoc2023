const std = @import("std");
const utils = @import("utils.zig");

const Cube = struct {
    color: []const u8,
    amount: u64,
};

const Bag = struct {
    blue: u64,
    green: u64,
    red: u64,
};

const Game = struct {
    const Self = @This();

    id: u64,
    bags: std.ArrayList(Bag),

    fn deinit(self: Self) void {
        self.bags.deinit();
    }
};

fn read_cube(data: []const u8) !Cube {
    var tokens = std.mem.tokenizeScalar(u8, data, ' ');
    const amount = try std.fmt.parseInt(u64, tokens.next().?, 10);
    const color = tokens.next().?;
    return Cube{
        .color = color,
        .amount = amount,
    };
}

fn read_bag(data: []const u8) !Bag {
    var tokens = std.mem.tokenizeScalar(u8, data, ',');
    var blue: u64 = 0;
    var green: u64 = 0;
    var red: u64 = 0;
    while (tokens.next()) |token| {
        const cube = try read_cube(token);
        if (std.mem.eql(u8, cube.color, "blue")) {
            blue = cube.amount;
        }
        if (std.mem.eql(u8, cube.color, "green")) {
            green = cube.amount;
        }
        if (std.mem.eql(u8, cube.color, "red")) {
            red = cube.amount;
        }
    }
    return Bag{
        .blue = blue,
        .green = green,
        .red = red,
    };
}

fn read_bags(data: []const u8, allocator: std.mem.Allocator) !std.ArrayList(Bag) {
    var tokens = std.mem.tokenizeScalar(u8, data, ';');
    var bags = std.ArrayList(Bag).init(allocator);
    while (tokens.next()) |token| {
        try bags.append(try read_bag(token));
    }
    return bags;
}

fn read_game(data: []const u8, allocator: std.mem.Allocator) !Game {
    var tokens = std.mem.tokenizeScalar(u8, data, ':');
    const id = try std.fmt.parseInt(u64, tokens.next().?[5..], 10);
    const bags = try read_bags(tokens.next().?, allocator);
    return Game{
        .id = id,
        .bags = bags,
    };
}

fn read_games(data: []const u8, allocator: std.mem.Allocator) !std.ArrayList(Game) {
    var lines = utils.lines(data);
    var games = std.ArrayList(Game).init(allocator);
    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        const game = try read_game(line, allocator);
        try games.append(game);
    }
    return games;
}

fn part1(games: std.ArrayList(Game)) u64 {
    const RED: u64 = 12;
    const GREEN: u64 = 13;
    const BLUE: u64 = 14;
    var sum: u64 = 0;
    for (games.items) |game| {
        a: {
            for (game.bags.items) |bag| {
                if (bag.blue > BLUE) {
                    break :a;
                }
                if (bag.green > GREEN) {
                    break :a;
                }
                if (bag.red > RED) {
                    break :a;
                }
            }
            sum += game.id;
        }
    }
    return sum;
}

fn part2(games: std.ArrayList(Game)) u64 {
    var sum: u64 = 0;
    for (games.items) |game| {
        var blue: u64 = 0;
        var green: u64 = 0;
        var red: u64 = 0;
        for (game.bags.items) |bag| {
            blue = @max(blue, bag.blue);
            green = @max(green, bag.green);
            red = @max(red, bag.red);
        }
        sum += blue * green * red;
    }
    return sum;
}

pub fn main() !void {
    const MAX_SIZE: usize = 1 << 15; // 32KB
    var data: [MAX_SIZE]u8 = undefined;
    const size = try utils.read(&data);
    const games = try read_games(data[0..size], std.heap.page_allocator);
    defer {
        for (games.items) |game| {
            game.deinit();
        }
        games.deinit();
    }
    try std.io.getStdOut().writer().print("part1 = {d}\n", .{part1(games)});
    try std.io.getStdOut().writer().print("part2 = {d}\n", .{part2(games)});
}
