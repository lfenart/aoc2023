const std = @import("std");
const utils = @import("utils.zig");

const Typ = enum(u3) {
    HighCard,
    OnePair,
    TwoPair,
    ThreeOfAKind,
    FullHouse,
    FourOfAKind,
    FiveOfAKind,
};

fn card_to_int(card: u8) u8 {
    if (utils.is_digit(card)) {
        return card - '2';
    } else {
        return switch (card) {
            'T' => 8,
            'J' => 9,
            'Q' => 10,
            'K' => 11,
            'A' => 12,
            else => unreachable,
        };
    }
}

fn card_to_int2(card: u8) u8 {
    if (utils.is_digit(card)) {
        return card - '1';
    } else {
        return switch (card) {
            'T' => 9,
            'J' => 0,
            'Q' => 10,
            'K' => 11,
            'A' => 12,
            else => unreachable,
        };
    }
}

const Hand = struct {
    cards: []const u8,
    bid: u64,
    typ: Typ,
    fn lessThan(_: void, a: Hand, b: Hand) bool {
        if (@intFromEnum(a.typ) < @intFromEnum(b.typ)) {
            return true;
        }
        if (@intFromEnum(a.typ) > @intFromEnum(b.typ)) {
            return false;
        }
        for (a.cards, b.cards) |card1, card2| {
            if (card_to_int(card1) < card_to_int(card2)) {
                return true;
            }
            if (card_to_int(card1) > card_to_int(card2)) {
                return false;
            }
        }
        return false;
    }
    fn lessThan2(_: void, a: Hand, b: Hand) bool {
        if (@intFromEnum(a.typ) < @intFromEnum(b.typ)) {
            return true;
        }
        if (@intFromEnum(a.typ) > @intFromEnum(b.typ)) {
            return false;
        }
        for (a.cards, b.cards) |card1, card2| {
            if (card_to_int2(card1) < card_to_int2(card2)) {
                return true;
            }
            if (card_to_int2(card1) > card_to_int2(card2)) {
                return false;
            }
        }
        return false;
    }
};

fn part1(data: []const u8) u64 {
    var hands = std.ArrayList(Hand).init(std.heap.page_allocator);
    defer hands.deinit();
    var lines = utils.lines(data);
    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        var it = std.mem.tokenizeScalar(u8, line, ' ');
        const cards = it.next().?;
        var kinds = [_]u8{0} ** 13;
        for (cards) |card| {
            const index: usize = card_to_int(card);
            kinds[index] += 1;
        }
        std.sort.insertion(u8, &kinds, @as(void, undefined), greaterThan);
        const typ = switch (kinds[0]) {
            1 => Typ.HighCard,
            2 => switch (kinds[1]) {
                2 => Typ.TwoPair,
                else => Typ.OnePair,
            },
            3 => switch (kinds[1]) {
                2 => Typ.FullHouse,
                else => Typ.ThreeOfAKind,
            },
            4 => Typ.FourOfAKind,
            5 => Typ.FiveOfAKind,
            else => unreachable,
        };
        const bid = std.fmt.parseInt(u64, it.next().?, 10) catch unreachable;
        hands.append(Hand{ .cards = cards, .typ = typ, .bid = bid }) catch unreachable;
    }
    std.sort.insertion(Hand, hands.items, @as(void, undefined), Hand.lessThan);
    var sum: u64 = 0;
    for (hands.items, 1..) |hand, i| {
        sum += i * hand.bid;
    }
    return sum;
}

fn part2(data: []const u8) u64 {
    var hands = std.ArrayList(Hand).init(std.heap.page_allocator);
    defer hands.deinit();
    var lines = utils.lines(data);
    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        var it = std.mem.tokenizeScalar(u8, line, ' ');
        const cards = it.next().?;
        var kinds = [_]u8{0} ** 13;
        for (cards) |card| {
            const index: usize = card_to_int2(card);
            kinds[index] += 1;
        }
        const jokers = kinds[0];
        kinds[0] = 0;
        std.sort.insertion(u8, &kinds, @as(void, undefined), greaterThan);
        const typ = switch (kinds[0] + jokers) {
            1 => Typ.HighCard,
            2 => switch (kinds[1]) {
                2 => Typ.TwoPair,
                else => Typ.OnePair,
            },
            3 => switch (kinds[1]) {
                2 => Typ.FullHouse,
                else => Typ.ThreeOfAKind,
            },
            4 => Typ.FourOfAKind,
            5 => Typ.FiveOfAKind,
            else => unreachable,
        };
        const bid = std.fmt.parseInt(u64, it.next().?, 10) catch unreachable;
        hands.append(Hand{ .cards = cards, .typ = typ, .bid = bid }) catch unreachable;
    }
    std.sort.insertion(Hand, hands.items, @as(void, undefined), Hand.lessThan2);
    var sum: u64 = 0;
    for (hands.items, 1..) |hand, i| {
        sum += i * hand.bid;
    }
    return sum;
}

fn greaterThan(_: void, a: u8, b: u8) bool {
    return a > b;
}

pub fn main() !void {
    const MAX_SIZE: usize = 1 << 15; // 32KB
    var data: [MAX_SIZE]u8 = undefined;
    const size = try utils.read(&data);
    try std.io.getStdOut().writer().print("part1 = {d}\n", .{part1(data[0..size])});
    try std.io.getStdOut().writer().print("part2 = {d}\n", .{part2(data[0..size])});
}
