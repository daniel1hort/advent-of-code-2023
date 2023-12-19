//! --- Day 18: Lavaduct Lagoon ---
//! Thanks to your efforts, the machine parts factory is one of the first factories up and running since the lavafall came back. However, to catch up with the large backlog of parts requests, the factory will also need a large supply of lava for a while; the Elves have already started creating a large lagoon nearby for this purpose.
//! However, they aren't sure the lagoon will be big enough; they've asked you to take a look at the dig plan (your puzzle input). For example:
//!
//! R 6 (#70c710)
//! D 5 (#0dc571)
//! L 2 (#5713f0)
//! D 2 (#d2c081)
//! R 2 (#59c680)
//! D 2 (#411b91)
//! L 5 (#8ceee2)
//! U 2 (#caa173)
//! L 1 (#1b58a2)
//! U 2 (#caa171)
//! R 2 (#7807d2)
//! U 3 (#a77fa3)
//! L 2 (#015232)
//! U 2 (#7a21e3)
//!
//! The digger starts in a 1 meter cube hole in the ground. They then dig the specified number of meters up (U), down (D), left (L), or right (R), clearing full 1 meter cubes as they go. The directions are given as seen from above, so if "up" were north, then "right" would be east, and so on. Each trench is also listed with the color that the edge of the trench should be painted as an RGB hexadecimal color code.
//! When viewed from above, the above example dig plan would result in the following loop of trench (#) having been dug out from otherwise ground-level terrain (.):
//!
//! #######
//! #.....#
//! ###...#
//! ..#...#
//! ..#...#
//! ###.###
//! #...#..
//! ##..###
//! .#....#
//! .######
//!
//! At this point, the trench could contain 38 cubic meters of lava. However, this is just the edge of the lagoon; the next step is to dig out the interior so that it is one meter deep as well:
//!
//! #######
//! #######
//! #######
//! ..#####
//! ..#####
//! #######
//! #####..
//! #######
//! .######
//! .######
//!
//! Now, the lagoon can contain a much more respectable 62 cubic meters of lava. While the interior is dug out, the edges are also painted according to the color codes in the dig plan.
//! The Elves are concerned the lagoon won't be large enough; if they follow their dig plan, how many cubic meters of lava could it hold?
//!
//! --- Part Two ---
//! The Elves were right to be concerned; the planned lagoon would be much too small.
//! After a few minutes, someone realizes what happened; someone swapped the color and instruction parameters when producing the dig plan. They don't have time to fix the bug; one of them asks if you can extract the correct instructions from the hexadecimal codes.
//! Each hexadecimal code is six hexadecimal digits long. The first five hexadecimal digits encode the distance in meters as a five-digit hexadecimal number. The last hexadecimal digit encodes the direction to dig: 0 means R, 1 means D, 2 means L, and 3 means U.
//! So, in the above example, the hexadecimal codes can be converted into the true instructions:
//!
//! #70c710 = R 461937
//! #0dc571 = D 56407
//! #5713f0 = R 356671
//! #d2c081 = D 863240
//! #59c680 = R 367720
//! #411b91 = D 266681
//! #8ceee2 = L 577262
//! #caa173 = U 829975
//! #1b58a2 = L 112010
//! #caa171 = D 829975
//! #7807d2 = L 491645
//! #a77fa3 = U 686074
//! #015232 = L 5411
//! #7a21e3 = U 500254
//!
//! Digging out this loop and its interior produces a lagoon that can hold an impressive 952408144115 cubic meters of lava.
//! Convert the hexadecimal color codes into the correct instructions; if the Elves follow this new dig plan, how many cubic meters of lava could the lagoon hold?

const std = @import("std");
const print = std.debug.print;
const abs = std.math.absInt;

const Coord = struct { x: i64, y: i64 };
const Instruction = struct {
    dir: u8,
    steps: u32,
};
const Vertex = struct {
    a: Coord,
    b: Coord,
};

fn vertexesFromInstructions(
    allocator: std.mem.Allocator,
    instructions: []const Instruction,
) ![]Vertex {
    var vertexes = std.ArrayList(Vertex).init(allocator);
    errdefer vertexes.deinit();
    var x: i64 = 0;
    var y: i64 = 0;

    for (instructions) |ins| {
        const steps: i64 = @intCast(ins.steps);

        var vertex: Vertex = .{ .a = .{ .x = x, .y = y }, .b = undefined };
        switch (ins.dir) {
            'U' => y -= steps,
            'L' => x -= steps,
            'D' => y += steps,
            'R' => x += steps,
            else => unreachable,
        }
        vertex.b = .{ .x = x, .y = y };
        try vertexes.append(vertex);
    }

    return vertexes.toOwnedSlice();
}

fn polygonArea(vertexes: []const Vertex) i64 {
    var area: i64 = 0;
    for (vertexes) |v| {
        area += v.a.x * v.b.y - v.b.x * v.a.y;
    }
    return area;
}

pub fn part1() !void {
    var arena_instance = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_instance.deinit();
    const allocator = arena_instance.allocator();

    const file = try std.fs.cwd().openFile("input/day18.in", .{});
    defer file.close();

    const file_contents = try file.readToEndAlloc(allocator, 10 * 4096);
    var line_it = std.mem.tokenizeSequence(u8, file_contents, "\r\n");

    var instructions = std.ArrayList(Instruction).init(allocator);
    while (line_it.next()) |line| {
        var value_it = std.mem.splitScalar(u8, line, ' ');
        const dir = value_it.next().?[0];
        const steps = try std.fmt.parseInt(i32, value_it.next().?, 10);
        try instructions.append(.{ .dir = dir, .steps = @intCast(steps) });
    }

    const vertexes = try vertexesFromInstructions(
        allocator,
        instructions.items,
    );

    var area = polygonArea(vertexes);
    for (instructions.items) |ins| {
        area += @intCast(ins.steps);
    }
    area = @divFloor(area, 2) + 1;

    print("day18 part1 answer = {d}\n", .{area});
}

pub fn part2() !void {
    var arena_instance = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_instance.deinit();
    const allocator = arena_instance.allocator();

    const file = try std.fs.cwd().openFile("input/day18.in", .{});
    defer file.close();

    const file_contents = try file.readToEndAlloc(allocator, 10 * 4096);
    var line_it = std.mem.tokenizeSequence(u8, file_contents, "\r\n");

    var instructions = std.ArrayList(Instruction).init(allocator);
    while (line_it.next()) |line| {
        var value_it = std.mem.splitScalar(u8, line, '#');
        _ = value_it.next();

        const value = value_it.next().?;
        const dir: u8 = switch (value[5]) {
            '0' => 'R',
            '1' => 'D',
            '2' => 'L',
            '3' => 'U',
            else => unreachable,
        };
        const steps = try std.fmt.parseInt(i32, value[0..5], 16);
        try instructions.append(.{ .dir = dir, .steps = @intCast(steps) });
    }

    const vertexes = try vertexesFromInstructions(
        allocator,
        instructions.items,
    );

    var area = polygonArea(vertexes);
    for (instructions.items) |ins| {
        area += @intCast(ins.steps);
    }
    area = @divFloor(area, 2) + 1;

    print("day18 part2 answer = {d}\n", .{area});
}
