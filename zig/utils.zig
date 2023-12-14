const std = @import("std");

pub fn read(buf: []u8) !usize {
    var stdin = std.io.bufferedReader(std.io.getStdIn().reader());
    var reader = stdin.reader();
    return try reader.readAll(buf);
}

pub fn lines(buf: []const u8) std.mem.TokenIterator(u8, .any) {
    return std.mem.tokenizeAny(u8, buf, "\n\r");
}

pub fn is_digit(c: u8) bool {
    return c >= '0' and c <= '9';
}
