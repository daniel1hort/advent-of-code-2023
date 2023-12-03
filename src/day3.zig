//! --- Day 3: Gear Ratios ---
//! You and the Elf eventually reach a gondola lift station; he says the gondola lift will take you up to the water source, but this is as far as he can bring you. You go inside.
//! It doesn't take long to find the gondolas, but there seems to be a problem: they're not moving.
//! "Aaah!"
//! You turn around to see a slightly-greasy Elf with a wrench and a look of surprise. "Sorry, I wasn't expecting anyone! The gondola lift isn't working right now; it'll still be a while before I can fix it." You offer to help.
//! The engineer explains that an engine part seems to be missing from the engine, but nobody can figure out which one. If you can add up all the part numbers in the engine schematic, it should be easy to work out which part is missing.
//! The engine schematic (your puzzle input) consists of a visual representation of the engine. There are lots of numbers and symbols you don't really understand, but apparently any number adjacent to a symbol, even diagonally, is a "part number" and should be included in your sum. (Periods (.) do not count as a symbol.)
//! Here is an example engine schematic:
//!
//! 467..114..
//! ...*......
//! ..35..633.
//! ......#...
//! 617*......
//! .....+.58.
//! ..592.....
//! ......755.
//! ...$.*....
//! .664.598..
//!
//! In this schematic, two numbers are not part numbers because they are not adjacent to a symbol: 114 (top right) and 58 (middle right). Every other number is adjacent to a symbol and so is a part number; their sum is 4361.
//! Of course, the actual engine schematic is much larger. What is the sum of all of the part numbers in the engine schematic?
//!
//! --- Part Two ---
//! The engineer finds the missing part and installs it in the engine! As the engine springs to life, you jump in the closest gondola, finally ready to ascend to the water source.
//! You don't seem to be going very fast, though. Maybe something is still wrong? Fortunately, the gondola has a phone labeled "help", so you pick it up and the engineer answers.
//! Before you can explain the situation, she suggests that you look out the window. There stands the engineer, holding a phone in one hand and waving with the other. You're going so slowly that you haven't even left the station. You exit the gondola.
//! The missing part wasn't the only issue - one of the gears in the engine is wrong. A gear is any * symbol that is adjacent to exactly two part numbers. Its gear ratio is the result of multiplying those two numbers together.
//! This time, you need to find the gear ratio of every gear and add them all up so that the engineer can figure out which gear needs to be replaced.
//! Consider the same engine schematic again:
//!
//! 467..114..
//! ...*......
//! ..35..633.
//! ......#...
//! 617*......
//! .....+.58.
//! ..592.....
//! ......755.
//! ...$.*....
//! .664.598..
//!
//! In this schematic, there are two gears. The first is in the top left; it has part numbers 467 and 35, so its gear ratio is 16345. The second gear is in the lower right; its gear ratio is 451490. (The * adjacent to 617 is not a gear because it is only adjacent to one part number.) Adding up all of the gear ratios produces 467835.
//! What is the sum of all of the gear ratios in your engine schematic?

const std = @import("std");

const Number = struct {
    value: u32,
    len: u32,
    line: u32,
    col: u32,
};

const Symbol = struct {
    value: u8,
    line: u32,
    col: u32,
};

fn collide(number: Number, symbol: Symbol) bool {
    const left = @as(i64, @intCast(number.col)) - 1;
    const right = number.col +% number.len;
    const top = @as(i64, @intCast(number.line)) - 1;
    const bottom = number.line +% 1;
    return left <= symbol.col and symbol.col <= right and top <= symbol.line and symbol.line <= bottom;
}

fn parseInt(source: []const u8) struct { u32, u32 } {
    var number: u32 = 0;
    var index: u32 = 0;
    for (source) |byte| {
        if (std.ascii.isDigit(byte)) {
            number = number * 10 + byte - '0';
            index = index + 1;
        } else {
            break;
        }
    }
    return .{ number, index };
}

fn parseInput() !struct{[]const Number, []const Symbol} {
    var file = try std.fs.cwd().openFile("input/day3.in", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buffer: [1024]u8 = undefined;
    var stream = std.io.fixedBufferStream(&buffer);
    var stream_writer = stream.writer();

    var symbols: [2000]Symbol = undefined;
    var symbols_count: u32 = 0;
    var numbers: [2000]Number = undefined;
    var numbers_count: u32 = 0;
    var line_count: u32 = 0;

    while (in_stream.streamUntilDelimiter(stream_writer, '\n', 1024)) {
        const line: []u8 = stream.getWritten();
        defer stream.reset();
        defer line_count += 1;

        var index: u32 = 0;
        while (index < line.len) : (index += 1) {
            const byte = line[index];
            if (byte == '.' or byte == '\r') continue;

            if (!std.ascii.isDigit(byte)) {
                symbols[symbols_count] = .{
                    .value = byte,
                    .line = line_count,
                    .col = index,
                };
                symbols_count += 1;
                continue;
            }

            const end = @min(line.len, index + 5);
            const number = parseInt(line[index..end]);
            numbers[numbers_count] = .{
                .value = number[0],
                .len = number[1],
                .line = line_count,
                .col = index,
            };

            numbers_count += 1;
            index += number[1] - 1;
        }
    } else |_| {}

    return .{numbers[0..numbers_count], symbols[0..symbols_count]};
}

pub fn part1() !void {
    const input = try parseInput();
    const numbers = input[0];
    const symbols = input[1];

    var sum: u32 = 0;
    number_it: for (numbers) |number| {
        for (symbols) |symbol| {
            if (collide(number, symbol)) {
                sum += number.value;
                continue :number_it;
            }
        }
    }

    std.debug.print("day3 part1 answer = {d}\n", .{sum});
}

pub fn part2() !void {
    const input = try parseInput();
    const numbers = input[0];
    const symbols = input[1];

    var sum: u32 = 0;
    for (symbols) |symbol| {
        if (symbol.value != '*') continue;

        var count: u32 = 0;
        var gear_ratio: u32 = 1;
        for (numbers) |number| {
            if (collide(number, symbol)) {
                count += 1;
                gear_ratio *= number.value;
            }
        }

        if (count == 2) {
            sum += gear_ratio;
        }
    }

    std.debug.print("day3 part2 answer = {d}\n", .{sum});
}
