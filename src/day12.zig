const std = @import("std");
const print = std.debug.print;

const Context = struct {
    springs: []const u8,
    groups: []const u32,
};

fn isSolution(config: []const u8, groups: []const u32) bool {
    var damaged_it = std.mem.tokenizeScalar(u8, config, '.');
    var index: u64 = 0;

    while (damaged_it.next()) |token| : (index += 1) {
        if (index >= groups.len or token.len != groups[index])
            return false;
    } else {
        if (index < groups.len)
            return false;
    }
    return true;
}

fn backtrack(springs: []const u8, groups: []const u32, config: []u8, level: u64) u32 {
    if (level >= springs.len) {
        return @intFromBool(isSolution(config, groups));
    }

    if (springs[level] != '?') {
        return backtrack(springs, groups, config, level + 1);
    }

    config[level] = '.';
    const solutions1: u32 = backtrack(springs, groups, config, level + 1);
    config[level] = '#';
    const solutions2: u32 = backtrack(springs, groups, config, level + 1);

    return solutions1 + solutions2;
}

pub fn part1() !void {
    var file = try std.fs.cwd().openFile("input/day12.in", .{});
    defer file.close();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    defer arena.deinit();
    const allocator = arena.allocator();

    const file_contents = try file.readToEndAlloc(allocator, 10 * 4096);
    var line_it = std.mem.tokenizeSequence(u8, file_contents, "\r\n");

    var sum: u32 = 0;
    while (line_it.next()) |line| {
        var part_it = std.mem.splitScalar(u8, line, ' ');

        const springs = part_it.next().?;
        var groups: [10]u32 = undefined;
        var groups_count: u32 = 0;

        const numbers_str = part_it.next().?;
        var numbers_it = std.mem.splitScalar(u8, numbers_str, ',');
        while (numbers_it.next()) |token| {
            groups[groups_count] = try std.fmt.parseInt(u32, token, 10);
            groups_count += 1;
        }

        var config: [100]u8 = undefined;
        std.mem.copy(u8, config[0..springs.len], springs);

        sum += backtrack(springs, groups[0..groups_count], config[0..springs.len], 0);
    }

    print("day12 part1 answer = {d}\n", .{sum});
}

pub fn part2() !void {
    var file = try std.fs.cwd().openFile("input/day12.in", .{});
    defer file.close();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    defer arena.deinit();
    const allocator = arena.allocator();

    const file_contents = try file.readToEndAlloc(allocator, 10 * 4096);
    _ = file_contents;

    print("day12 part2 answer = {d}\n", .{0});
}
