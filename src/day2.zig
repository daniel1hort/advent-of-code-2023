const std = @import("std");

pub fn part1() !void {
    var file = try std.fs.cwd().openFile("input/day2.in", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buffer: [1024]u8 = undefined;
    var stream = std.io.fixedBufferStream(&buffer);
    var stream_writer = stream.writer();

    var count: u32 = 0;
    var sum: u32 = 0;

    while (in_stream.streamUntilDelimiter(stream_writer, '\n', 1024)) {
        const line: []u8 = stream.getWritten();
        defer stream.reset();

        count = count + 1;
        var red: u32 = 0;
        var blue: u32 = 0;
        var green: u32 = 0;
        var it = std.mem.split(u8, line[5..line.len], " ");
        _ = it.next(); // discard line number;

        while (true) {
            const token1 = it.next();
            if (token1 == null) break;
            const token2 = it.next();

            const number = std.fmt.parseInt(u32, token1.?, 10) catch unreachable;
            switch (token2.?[0]) {
                'r' => red = @max(red, number),
                'g' => green = @max(green, number),
                'b' => blue = @max(blue, number),
                else => {},
            }
        }

        if (red <= 12 and green <= 13 and blue <= 14)
            sum = sum + count;
    } else |_| {}

    std.debug.print("day2 part1 answer = {d}\n", .{sum});
}

pub fn part2() !void {
    var file = try std.fs.cwd().openFile("input/day2.in", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buffer: [1024]u8 = undefined;
    var stream = std.io.fixedBufferStream(&buffer);
    var stream_writer = stream.writer();

    var count: u32 = 0;
    var sum: u32 = 0;

    while (in_stream.streamUntilDelimiter(stream_writer, '\n', 1024)) {
        const line: []u8 = stream.getWritten();
        defer stream.reset();

        count = count + 1;
        var red: u32 = 0;
        var blue: u32 = 0;
        var green: u32 = 0;
        var it = std.mem.split(u8, line[5..line.len], " ");
        _ = it.next(); // discard line number;

        while (true) {
            const token1 = it.next();
            if (token1 == null) break;
            const token2 = it.next();

            const number = std.fmt.parseInt(u32, token1.?, 10) catch unreachable;
            switch (token2.?[0]) {
                'r' => red = @max(red, number),
                'g' => green = @max(green, number),
                'b' => blue = @max(blue, number),
                else => {},
            }
        }

        sum = sum + red * green * blue;
    } else |_| {}

    std.debug.print("day2 part2 answer = {d}\n", .{sum});
}
