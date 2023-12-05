//! --- Day 5: If You Give A Seed A Fertilizer ---
//! You take the boat and find the gardener right where you were told he would be: managing a giant "garden" that looks more to you like a farm.
//! "A water source? Island Island is the water source!" You point out that Snow Island isn't receiving any water.
//! "Oh, we had to stop the water because we ran out of sand to filter it with! Can't make snow with dirty water. Don't worry, I'm sure we'll get more sand soon; we only turned off the water a few days... weeks... oh no." His face sinks into a look of horrified realization.
//! "I've been so busy making sure everyone here has food that I completely forgot to check why we stopped getting more sand! There's a ferry leaving soon that is headed over in that direction - it's much faster than your boat. Could you please go check it out?"
//! You barely have time to agree to this request when he brings up another. "While you wait for the ferry, maybe you can help us with our food production problem. The latest Island Island Almanac just arrived and we're having trouble making sense of it."
//! The almanac (your puzzle input) lists all of the seeds that need to be planted. It also lists what type of soil to use with each kind of seed, what type of fertilizer to use with each kind of soil, what type of water to use with each kind of fertilizer, and so on. Every type of seed, soil, fertilizer and so on is identified with a number, but numbers are reused by each category - that is, soil 123 and fertilizer 123 aren't necessarily related to each other.
//! For example:
//!
//! seeds: 79 14 55 13
//!
//! seed-to-soil map:
//! 50 98 2
//! 52 50 48
//!
//! soil-to-fertilizer map:
//! 0 15 37
//! 37 52 2
//! 39 0 15
//!
//! fertilizer-to-water map:
//! 49 53 8
//! 0 11 42
//! 42 0 7
//! 57 7 4
//!
//! water-to-light map:
//! 88 18 7
//! 18 25 70
//!
//! light-to-temperature map:
//! 45 77 23
//! 81 45 19
//! 68 64 13
//!
//! temperature-to-humidity map:
//! 0 69 1
//! 1 0 69
//!
//! humidity-to-location map:
//! 60 56 37
//! 56 93 4
//!
//! The almanac starts by listing which seeds need to be planted: seeds 79, 14, 55, and 13.
//! The rest of the almanac contains a list of maps which describe how to convert numbers from a source category into numbers in a destination category. That is, the section that starts with seed-to-soil map: describes how to convert a seed number (the source) to a soil number (the destination). This lets the gardener and his team know which soil to use with which seeds, which water to use with which fertilizer, and so on.
//! Rather than list every source number and its corresponding destination number one by one, the maps describe entire ranges of numbers that can be converted. Each line within a map contains three numbers: the destination range start, the source range start, and the range length.
//! Consider again the example seed-to-soil map:
//!
//! 50 98 2
//! 52 50 48
//!
//! The first line has a destination range start of 50, a source range start of 98, and a range length of 2. This line means that the source range starts at 98 and contains two values: 98 and 99. The destination range is the same length, but it starts at 50, so its two values are 50 and 51. With this information, you know that seed number 98 corresponds to soil number 50 and that seed number 99 corresponds to soil number 51.
//! The second line means that the source range starts at 50 and contains 48 values: 50, 51, ..., 96, 97. This corresponds to a destination range starting at 52 and also containing 48 values: 52, 53, ..., 98, 99. So, seed number 53 corresponds to soil number 55.
//! Any source numbers that aren't mapped correspond to the same destination number. So, seed number 10 corresponds to soil number 10.
//! So, the entire list of seed numbers and their corresponding soil numbers looks like this:
//!
//! seed  soil
//! 0     0
//! 1     1
//! ...   ...
//! 48    48
//! 49    49
//! 50    52
//! 51    53
//! ...   ...
//! 96    98
//! 97    99
//! 98    50
//! 99    51
//!
//! With this map, you can look up the soil number required for each initial seed number:
//! Seed number 79 corresponds to soil number 81.
//! Seed number 14 corresponds to soil number 14.
//! Seed number 55 corresponds to soil number 57.
//! Seed number 13 corresponds to soil number 13.
//! The gardener and his team want to get started as soon as possible, so they'd like to know the closest location that needs a seed. Using these maps, find the lowest location number that corresponds to any of the initial seeds. To do this, you'll need to convert each seed number through other categories until you can find its corresponding location number. In this example, the corresponding types are:
//! Seed 79, soil 81, fertilizer 81, water 81, light 74, temperature 78, humidity 78, location 82.
//! Seed 14, soil 14, fertilizer 53, water 49, light 42, temperature 42, humidity 43, location 43.
//! Seed 55, soil 57, fertilizer 57, water 53, light 46, temperature 82, humidity 82, location 86.
//! Seed 13, soil 13, fertilizer 52, water 41, light 34, temperature 34, humidity 35, location 35.
//! So, the lowest location number in this example is 35.
//! What is the lowest location number that corresponds to any of the initial seed numbers?
//!
//! --- Part Two ---
//! Everyone will starve if you only plant such a small number of seeds. Re-reading the almanac, it looks like the seeds: line actually describes ranges of seed numbers.
//! The values on the initial seeds: line come in pairs. Within each pair, the first value is the start of the range and the second value is the length of the range. So, in the first line of the example above:
//! seeds: 79 14 55 13
//! This line describes two ranges of seed numbers to be planted in the garden. The first range starts with seed number 79 and contains 14 values: 79, 80, ..., 91, 92. The second range starts with seed number 55 and contains 13 values: 55, 56, ..., 66, 67.
//! Now, rather than considering four seed numbers, you need to consider a total of 27 seed numbers.
//! In the above example, the lowest location number can be obtained from seed number 82, which corresponds to soil 84, fertilizer 84, water 84, light 77, temperature 45, humidity 46, and location 46. So, the lowest location number is 46.
//! Consider all of the initial seed numbers listed in the ranges on the first line of the almanac. What is the lowest location number that corresponds to any of the initial seed numbers?

const std = @import("std");

const MapRow = struct {
    source: u64,
    destination: u64,
    length: u64,
};

var seeds: [50]u64 = undefined;
var seeds_count: u32 = undefined;
var maps: [7][100]MapRow = undefined;
var map_counts: [7]u32 = undefined;

fn sort() void {
    var aux: MapRow = undefined;
    for (&maps, 0..) |*map, index| {
        for (0..map_counts[index] - 1) |i| {
            for (i + 1..map_counts[index]) |j| {
                if (map[i].source > map[j].source) {
                    aux = map[i];
                    map[i] = map[j];
                    map[j] = aux;
                }
            }
        }
    }
}

fn fillGaps() void {
    for (&maps, 0..) |*map, index| {
        var i = map_counts[index] - 1;

        map[map_counts[index]] = .{
            .destination = map[i].source + map[i].length,
            .source = map[i].source + map[i].length,
            .length = std.math.maxInt(u64) - map[i].source - map[i].length,
        };
        map_counts[index] += 1;

        if (map[0].source != 0) {
            map[map_counts[index]] = .{
                .destination = 0,
                .source = 0,
                .length = map[0].source,
            };
            map_counts[index] += 1;
        }

        while (i > 0) : (i -= 1) {
            const first = map[i - 1];
            const second = map[i];
            const limit = first.source + first.length;
            const difference = second.source - limit;
            if (difference > 1) {
                map[map_counts[index]] = .{
                    .destination = limit,
                    .source = limit,
                    .length = difference,
                };
                map_counts[index] += 1;
            }
        }
    }
}

fn solution(first: u64, last: u64, index: u32) u64 {
    if (index == maps.len) {
        return first;
    }

    var min: u64 = std.math.maxInt(u64);
    var begin = first;

    for (0..map_counts[index]) |i| {
        const row = maps[index][i];
        if (row.source > last) break;

        if (row.source <= begin and begin < row.source + row.length) {
            const end = @min(last, row.source + row.length - 1);

            const new_first = row.destination + begin - row.source;
            const new_last = row.destination + end - row.source;

            const result = solution(
                new_first,
                new_last,
                index + 1,
            );

            begin = row.source + row.length;
            min = @min(result, min);
        }
    }

    return min;
}

fn parseInput() !void {
    var file = try std.fs.cwd().openFile("input/day5.in", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buffer: [1024]u8 = undefined;
    var stream = std.io.fixedBufferStream(&buffer);
    var stream_writer = stream.writer();

    seeds_count = 0;
    try in_stream.streamUntilDelimiter(stream_writer, '\n', 1024);
    const first_line = stream.getWritten();
    var seeds_it = std.mem.split(u8, first_line[7 .. first_line.len - 1], " ");
    while (seeds_it.next()) |token| {
        const number = try std.fmt.parseInt(u64, token, 10);
        seeds[seeds_count] = number;
        seeds_count += 1;
    }
    stream.reset();

    var count: u32 = 0;
    @memset(&map_counts, 0);

    while (in_stream.streamUntilDelimiter(stream_writer, '\n', 1024)) {
        var line: []u8 = stream.getWritten();
        defer stream.reset();

        if (line.len == 1) {
            try in_stream.streamUntilDelimiter(stream_writer, '\n', 1024);
            count += 1;
            continue;
        }

        var map_it = std.mem.split(u8, line[0 .. line.len - 1], " ");
        maps[count - 1][map_counts[count - 1]] = .{
            .destination = try std.fmt.parseInt(u64, map_it.next().?, 10),
            .source = try std.fmt.parseInt(u64, map_it.next().?, 10),
            .length = try std.fmt.parseInt(u64, map_it.next().?, 10),
        };
        map_counts[count - 1] += 1;
    } else |_| {}

    sort();
    fillGaps();
    sort();
}

pub fn part1() !void {
    try parseInput();

    var min: u64 = std.math.maxInt(u64);
    for (0..seeds_count) |index| {
        var current = seeds[index];

        middle: for (0..maps.len) |i| {
            for (0..map_counts[i]) |j| {
                const row = maps[i][j];

                if (row.source <= current and current < row.source + row.length) {
                    const result = row.destination + (current - row.source);
                    current = result;
                    continue :middle;
                }
            }
        }

        min = @min(min, current);
    }

    std.debug.print("day5 part1 answer = {d}\n", .{min});
}

pub fn part2() !void {
    try parseInput();
    var min: u64 = std.math.maxInt(u64);

    for (0..seeds_count / 2) |index| {
        const first = seeds[2 * index];
        const last = first + seeds[2 * index + 1] - 1;

        const result = solution(
            first,
            last,
            0,
        );

        min = @min(result, min);
    }

    std.debug.print("day5 part2 answer = {d}\n", .{min});
}
