const std = @import("std");

const Hand = struct {
    cards: [5]u8 = undefined,
    bid: u32 = undefined,
};

fn parseInt(source: []const u8) u32 {
    var number: u32 = 0;
    for (source) |byte| {
        if (std.ascii.isDigit(byte)) {
            number = number * 10 + byte - '0';
        }
    }
    return number;
}

fn mapLabel(label: u8, use_jokers: bool) u32 {
    return switch (label) {
        '0'...'9' => |value| value - '0',
        'T' => 10,
        'J' => if(use_jokers) 0 else 11,
        'Q' => 12,
        'K' => 13,
        'A' => 14,
        else => 0,
    };
}

fn rank(hand: Hand, use_jokers: bool) u32 {
    var labels_count: [15]u32 = undefined;
    @memset(&labels_count, 0);

    for (hand.cards) |label| {
        labels_count[mapLabel(label, true)] += 1;
    }

    const jokers = if(use_jokers) blk:{ 
        const aux = labels_count[0];
        labels_count[0] = 0;
        break :blk aux;
    } else 0;

    std.mem.sort(
        u32,
        &labels_count,
        {},
        std.sort.desc(u32),
    );
    labels_count[0] += jokers;

    var has3: bool = false;
    var has2: bool = false;
    var has22: bool = false;

    for (labels_count) |count| {
        if (count == 0) break;

        switch (count) {
            5, 4 => |value| return value + 2,
            3 => has3 = true,
            2 => if (has2) {
                has22 = true;
            } else {
                has2 = true;
            },
            else => {},
        }
    }

    if (has3 and has2) return 5;
    if (has3) return 4;
    if (has22) return 3;
    if (has2) return 2;
    return 1;
}

fn compareHand(context: bool, a: Hand, b: Hand) bool {
    const rank_a = rank(a, context);
    const rank_b = rank(b, context);

    if (rank_a < rank_b) {
        return true;
    } else if (rank_a > rank_b) {
        return false;
    } else {
        for (a.cards, b.cards) |label_a, label_b| {
            const strength_a = mapLabel(label_a, context);
            const strength_b = mapLabel(label_b, context);

            if (strength_a < strength_b) {
                return true;
            } else if (strength_a > strength_b) {
                return false;
            }
        }
    }

    return false;
}

fn parseInput(hands: []Hand) !void {
    var file = try std.fs.cwd().openFile("input/day7.in", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buffer: [1024]u8 = undefined;
    var stream = std.io.fixedBufferStream(&buffer);
    var stream_writer = stream.writer();

    var hands_count: u32 = 0;
    while (in_stream.streamUntilDelimiter(stream_writer, '\n', 1024)) {
        const line: []u8 = stream.getWritten();
        defer stream.reset();

        var hand: Hand = undefined;
        std.mem.copy(u8, &hand.cards, line[0..5]);
        hand.bid = parseInt(line[5..]);

        hands[hands_count] = hand;
        hands_count += 1;
    } else |_| {}
}

pub fn part1() !void {
    var hands: [1000]Hand = undefined;
    try parseInput(&hands);

    std.mem.sort(
        Hand,
        &hands,
        false,
        compareHand,
    );

    var sum: u64 = 0;
    for (hands, 1..) |hand, order| {
        sum += hand.bid * order;
    }

    std.debug.print("day7 part1 answer = {d}\n", .{sum});
}

pub fn part2() !void {
    var hands: [1000]Hand = undefined;
    try parseInput(&hands);

    std.mem.sort(
        Hand,
        &hands,
        true,
        compareHand,
    );

    var sum: u64 = 0;
    for (hands, 1..) |hand, order| {
        sum += hand.bid * order;
    }

    std.debug.print("day7 part2 answer = {d}\n", .{sum});
}
