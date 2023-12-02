const std = @import("std");

const digits = [_]u64{
    hash("zero"), // not valid but index starts at zero ¯\_(ツ)_/¯
    hash("one"),
    hash("two"),
    hash("three"),
    hash("four"),
    hash("five"),
    hash("six"),
    hash("seven"),
    hash("eight"),
    hash("nine"),
};

fn indexOf(array: []const u64, to_find: u64) usize {
    for (array, 0..) |element, index| {
        if (element == to_find) {
            return index;
        }
    }
    return 0; // should return error here but ¯\_(ツ)_/¯
}

fn hash(data: []const u8) u64 {
    var sum: u64 = 0;
    var factor: u64 = 1;

    for (data) |byte| {
        sum = sum + byte * factor;
        factor = factor * 13;
    }

    return sum;
}

pub fn part1() !void {
    var file = try std.fs.cwd().openFile("input/day1.in", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var first_digit: u8 = undefined;
    var last_digit: u8 = undefined;
    var sum: u32 = 0;
    var count: u32 = 0;

    while (in_stream.readByte()) |byte| {
        if (std.ascii.isDigit(byte)) {
            count = count + 1;
            last_digit = byte - '0';
            if (count == 1) {
                first_digit = last_digit;
            }
        } else if (byte == '\n') {
            count = 0;
            sum = sum + first_digit * 10 + last_digit;
        }
    } else |_| {}

    std.debug.print("day1 part1 answer = {d}\n", .{sum});
}

pub fn part2() !void {
    var file = try std.fs.cwd().openFile("input/day1.in", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buffer: [1024]u8 = undefined;
    var stream = std.io.fixedBufferStream(&buffer);
    var stream_writer = stream.writer();

    var first_digit: u8 = undefined;
    var last_digit: u8 = undefined;
    var sum: u32 = 0;
    var count: u32 = 0;

    while (in_stream.streamUntilDelimiter(stream_writer, '\n', 1024)) {
        const line = stream.getWritten();
        defer stream.reset();

        for (line, 0..) |byte, index| {
            if (std.ascii.isDigit(byte)) {
                count = count + 1;
                last_digit = byte - '0';
                if (count == 1) {
                    first_digit = last_digit;
                }
            } else {
                const len = @min(index + 6, line.len);
                if(len - index < 3) continue;

                for(index+3..len) |end| {
                    const data = line[index..end];
                    const hash_value = hash(data);
                    const digit = indexOf(&digits, hash_value);

                    if (digit > 0) {
                        count = count + 1;
                        last_digit = @intCast(digit);
                        if (count == 1) {
                            first_digit = last_digit;
                        }
                    }
                }
            }
        }
        
        count = 0;
        sum = sum + first_digit * 10 + last_digit;
    } else |_| {}

    std.debug.print("day1 part2 answer = {d}\n", .{sum});
}