//! --- Day 1: Trebuchet?! ---
//! Something is wrong with global snow production, and you've been selected to take a look. The Elves have even given you a map; on it, they've used stars to mark the top fifty locations that are likely to be having problems.
//! You've been doing this long enough to know that to restore snow operations, you need to check all fifty stars by December 25th.
//! Collect stars by solving puzzles. Two puzzles will be made available on each day in the Advent calendar; the second puzzle is unlocked when you complete the first. Each puzzle grants one star. Good luck!
//! You try to ask why they can't just use a weather machine ("not powerful enough") and where they're even sending you ("the sky") and why your map looks mostly blank ("you sure ask a lot of questions") and hang on did you just say the sky ("of course, where do you think snow comes from") when you realize that the Elves are already loading you into a trebuchet ("please hold still, we need to strap you in").
//! As they're making the final adjustments, they discover that their calibration document (your puzzle input) has been amended by a very young Elf who was apparently just excited to show off her art skills. Consequently, the Elves are having trouble reading the values on the document.
//! The newly-improved calibration document consists of lines of text; each line originally contained a specific calibration value that the Elves now need to recover. On each line, the calibration value can be found by combining the first digit and the last digit (in that order) to form a single two-digit number.
//! For example:
//! 
//! 1abc2
//! pqr3stu8vwx
//! a1b2c3d4e5f
//! treb7uchet
//!
//! In this example, the calibration values of these four lines are 12, 38, 15, and 77. Adding these together produces 142.
//! Consider your entire calibration document. What is the sum of all of the calibration values?
//!
//! --- Part Two ---
//! Your calculation isn't quite right. It looks like some of the digits are actually spelled out with letters: one, two, three, four, five, six, seven, eight, and nine also count as valid "digits".
//! Equipped with this new information, you now need to find the real first and last digit on each line. For example:
//!
//! two1nine
//! eightwothree
//! abcone2threexyz
//! xtwone3four
//! 4nineeightseven2
//! zoneight234
//! 7pqrstsixteen
//!
//! In this example, the calibration values are 29, 83, 13, 24, 42, 14, and 76. Adding these together produces 281.
//! What is the sum of all of the calibration values?

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
