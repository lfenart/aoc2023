const std = @import("std");

pub fn read(buf: []u8) !usize {
    var stdin = std.io.bufferedReader(std.io.getStdIn().reader());
    var reader = stdin.reader();
    return try reader.readAll(buf);
}

pub fn lines(buf: []const u8) std.mem.SplitIterator(u8, .sequence) {
    return std.mem.splitSequence(u8, buf, "\r\n");
}

pub fn is_digit(c: u8) bool {
    return c >= '0' and c <= '9';
}
