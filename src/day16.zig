//! --- Day 16: The Floor Will Be Lava ---
//! With the beam of light completely focused somewhere, the reindeer leads you deeper still into the Lava Production Facility. At some point, you realize that the steel facility walls have been replaced with cave, and the doorways are just cave, and the floor is cave, and you're pretty sure this is actually just a giant cave.
//! Finally, as you approach what must be the heart of the mountain, you see a bright light in a cavern up ahead. There, you discover that the beam of light you so carefully focused is emerging from the cavern wall closest to the facility and pouring all of its energy into a contraption on the opposite side.
//! Upon closer inspection, the contraption appears to be a flat, two-dimensional square grid containing empty space (.), mirrors (/ and \), and splitters (| and -).
//! The contraption is aligned so that most of the beam bounces around the grid, but each tile on the grid converts some of the beam's light into heat to melt the rock in the cavern.
//! You note the layout of the contraption (your puzzle input). For example:
//!
//! .|...\....
//! |.-.\.....
//! .....|-...
//! ........|.
//! ..........
//! .........\
//! ..../.\\..
//! .-.-/..|..
//! .|....-|.\
//! ..//.|....
//!
//! The beam enters in the top-left corner from the left and heading to the right. Then, its behavior depends on what it encounters as it moves:
//! If the beam encounters empty space (.), it continues in the same direction.
//! If the beam encounters a mirror (/ or \), the beam is reflected 90 degrees depending on the angle of the mirror. For instance, a rightward-moving beam that encounters a / mirror would continue upward in the mirror's column, while a rightward-moving beam that encounters a \ mirror would continue downward from the mirror's column.
//! If the beam encounters the pointy end of a splitter (| or -), the beam passes through the splitter as if the splitter were empty space. For instance, a rightward-moving beam that encounters a - splitter would continue in the same direction.
//! If the beam encounters the flat side of a splitter (| or -), the beam is split into two beams going in each of the two directions the splitter's pointy ends are pointing. For instance, a rightward-moving beam that encounters a | splitter would split into two beams: one that continues upward from the splitter's column and one that continues downward from the splitter's column.
//! Beams do not interact with other beams; a tile can have many beams passing through it at the same time. A tile is energized if that tile has at least one beam pass through it, reflect in it, or split in it.
//! In the above example, here is how the beam of light bounces around the contraption:
//!
//! >|<<<\....
//! |v-.\^....
//! .v...|->>>
//! .v...v^.|.
//! .v...v^...
//! .v...v^..\
//! .v../2\\..
//! <->-/vv|..
//! .|<<<2-|.\
//! .v//.|.v..
//!
//! Beams are only shown on empty tiles; arrows indicate the direction of the beams. If a tile contains beams moving in multiple directions, the number of distinct directions is shown instead. Here is the same diagram but instead only showing whether a tile is energized (#) or not (.):
//!
//! ######....
//! .#...#....
//! .#...#####
//! .#...##...
//! .#...##...
//! .#...##...
//! .#..####..
//! ########..
//! .#######..
//! .#...#.#..
//!
//! Ultimately, in this example, 46 tiles become energized.
//! The light isn't energizing enough tiles to produce lava; to debug the contraption, you need to start by analyzing the current situation. With the beam starting in the top-left heading right, how many tiles end up being energized?
//!
//! --- Part Two ---
//! As you try to work out what might be wrong, the reindeer tugs on your shirt and leads you to a nearby control panel. There, a collection of buttons lets you align the contraption so that the beam enters from any edge tile and heading away from that edge. (You can choose either of two directions for the beam if it starts on a corner; for instance, if the beam starts in the bottom-right corner, it can start heading either left or upward.)
//! So, the beam could start on any tile in the top row (heading downward), any tile in the bottom row (heading upward), any tile in the leftmost column (heading right), or any tile in the rightmost column (heading left). To produce lava, you need to find the configuration that energizes as many tiles as possible.
//! In the above example, this can be achieved by starting the beam in the fourth tile from the left in the top row:
//!
//! .|<2<\....
//! |v-v\^....
//! .v.v.|->>>
//! .v.v.v^.|.
//! .v.v.v^...
//! .v.v.v^..\
//! .v.v/2\\..
//! <-2-/vv|..
//! .|<<<2-|.\
//! .v//.|.v..
//!
//! Using this configuration, 51 tiles are energized:
//!
//! .#####....
//! .#.#.#....
//! .#.#.#####
//! .#.#.##...
//! .#.#.##...
//! .#.#.##...
//! .#.#####..
//! ########..
//! .#######..
//! .#...#.#..
//!
//! Find the initial beam configuration that energizes the largest number of tiles; how many tiles are energized in that configuration?

const std = @import("std");
const print = std.debug.print;

const Coord = struct { x: i64, y: i64 };
const Direction = enum { up, left, down, right };
const Ray = struct { pos: Coord, dir: Direction };

fn next(matrix: [][]const u8, ray: Ray) ?Ray {
    const bounds: Coord = .{
        .x = @intCast(matrix[0].len),
        .y = @intCast(matrix.len),
    };
    const tile = matrix[@intCast(ray.pos.y)][@intCast(ray.pos.x)];

    const next_pos: struct { i64, i64, Direction } = switch (tile) {
        '.' => switch (ray.dir) {
            .up => .{ ray.pos.x, ray.pos.y - 1, .up },
            .left => .{ ray.pos.x - 1, ray.pos.y, .left },
            .down => .{ ray.pos.x, ray.pos.y + 1, .down },
            .right => .{ ray.pos.x + 1, ray.pos.y, .right },
        },
        '/' => switch (ray.dir) {
            .up => .{ ray.pos.x + 1, ray.pos.y, .right },
            .left => .{ ray.pos.x, ray.pos.y + 1, .down },
            .down => .{ ray.pos.x - 1, ray.pos.y, .left },
            .right => .{ ray.pos.x, ray.pos.y - 1, .up },
        },
        '\\' => switch (ray.dir) {
            .up => .{ ray.pos.x - 1, ray.pos.y, .left },
            .left => .{ ray.pos.x, ray.pos.y - 1, .up },
            .down => .{ ray.pos.x + 1, ray.pos.y, .right },
            .right => .{ ray.pos.x, ray.pos.y + 1, .down },
        },
        '|' => switch (ray.dir) {
            .up => .{ ray.pos.x, ray.pos.y - 1, .up },
            .down => .{ ray.pos.x, ray.pos.y + 1, .down },
            else => unreachable,
        },
        '-' => switch (ray.dir) {
            .left => .{ ray.pos.x - 1, ray.pos.y, .left },
            .right => .{ ray.pos.x + 1, ray.pos.y, .right },
            else => unreachable,
        },
        else => unreachable,
    };

    if (next_pos[0] < 0 or next_pos[0] >= bounds.x or next_pos[1] < 0 or next_pos[1] >= bounds.y) {
        return null;
    }

    return .{
        .pos = .{ .x = @intCast(next_pos[0]), .y = @intCast(next_pos[1]) },
        .dir = next_pos[2],
    };
}

fn split(matrix: [][]const u8, ray: Ray) [2]?Ray {
    const bounds: Coord = .{
        .x = @intCast(matrix[0].len),
        .y = @intCast(matrix.len),
    };
    const tile = matrix[@intCast(ray.pos.y)][@intCast(ray.pos.x)];

    const next_pos: [2]struct { i64, i64, Direction } = switch (tile) {
        '|' => switch (ray.dir) {
            .left, .right => .{
                .{ ray.pos.x, ray.pos.y - 1, .up },
                .{ ray.pos.x, ray.pos.y + 1, .down },
            },
            else => unreachable,
        },
        '-' => switch (ray.dir) {
            .up, .down => .{
                .{ ray.pos.x - 1, ray.pos.y, .left },
                .{ ray.pos.x + 1, ray.pos.y, .right },
            },
            else => unreachable,
        },
        else => unreachable,
    };

    var rays: [2]?Ray = undefined;
    for (next_pos, 0..) |pos, index| {
        if (pos[0] < 0 or pos[0] >= bounds.x or pos[1] < 0 or pos[1] >= bounds.y) {
            rays[index] = null;
        } else {
            rays[index] = .{ .pos = .{ .x = pos[0], .y = pos[1] }, .dir = pos[2] };
        }
    }
    return rays;
}

fn shouldSplit(matrix: [][]const u8, ray: Ray) bool {
    const tile = matrix[@intCast(ray.pos.y)][@intCast(ray.pos.x)];
    return tile == '|' and (ray.dir == .left or ray.dir == .right) or 
        tile == '-' and (ray.dir == .up or ray.dir == .down);
}

fn mark(dir: Direction) u8 {
    return switch (dir) {
        .up => '^',
        .left => '<',
        .down => 'v',
        .right => '>',
    };
}

fn solve(
    start_ray: Ray,
    rays: *std.ArrayList(Ray),
    matrix: [][]const u8,
    energized: [][]u8,
) !u32 {
    var count: u32 = 0;
    try rays.append(start_ray);

    while (rays.items.len > 0) : (count += 1) {
        const ray = rays.orderedRemove(0);
        var marker = mark(ray.dir);
        if (energized[@intCast(ray.pos.y)][@intCast(ray.pos.x)] == marker) {
            continue;
        }

        energized[@intCast(ray.pos.y)][@intCast(ray.pos.x)] = marker;
        if (shouldSplit(matrix, ray)) {
            const next_poss = split(matrix, ray);
            for (next_poss) |next_pos| {
                if (next_pos) |pos| {
                    try rays.append(pos);
                }
            }
        } else {
            const next_pos = next(matrix, ray);
            if (next_pos) |pos| {
                try rays.append(pos);
            }
        }
    }

    var sum: u32 = 0;
    for (energized) |row| {
        for (row) |byte| {
            if (byte != '.') {
                sum += 1;
            }
        }
    }
    return sum;
}

pub fn part1() !void {
    var file = try std.fs.cwd().openFile("input/day16.in", .{});
    defer file.close();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    defer arena.deinit();
    const allocator = arena.allocator();

    const file_contents = try file.readToEndAlloc(allocator, 10 * 4096);
    var line_it = std.mem.tokenizeSequence(u8, file_contents, "\r\n");

    var matrix = std.ArrayList([]const u8).init(allocator);
    while (line_it.next()) |line| {
        try matrix.append(line);
    }

    const cols = matrix.items[0].len;
    const total_size = matrix.items.len * matrix.items[0].len;
    const energized_contents = try allocator.alloc(u8, total_size);
    @memset(energized_contents, '.');
    var energized = std.ArrayList([]u8).init(allocator);
    for (0..matrix.items.len) |index| {
        try energized.append(energized_contents[index * cols .. (index + 1) * cols]);
    }

    var rays = std.ArrayList(Ray).init(allocator);
    const start_ray = .{ .pos = .{ .x = 0, .y = 0 }, .dir = .right };
    const sum = try solve(
        start_ray,
        &rays,
        matrix.items,
        energized.items,
    );

    print("day16 part1 answer = {d}\n", .{sum});
}

pub fn part2() !void {
    var file = try std.fs.cwd().openFile("input/day16.in", .{});
    defer file.close();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    defer arena.deinit();
    const allocator = arena.allocator();

    const file_contents = try file.readToEndAlloc(allocator, 10 * 4096);
    var line_it = std.mem.tokenizeSequence(u8, file_contents, "\r\n");

    var matrix = std.ArrayList([]const u8).init(allocator);
    while (line_it.next()) |line| {
        try matrix.append(line);
    }

    const cols = matrix.items[0].len;
    const rows = matrix.items.len;
    const total_size = matrix.items.len * matrix.items[0].len;
    const energized_contents = try allocator.alloc(u8, total_size);
    @memset(energized_contents, '.');
    var energized = std.ArrayList([]u8).init(allocator);
    for (0..matrix.items.len) |index| {
        try energized.append(energized_contents[index * cols .. (index + 1) * cols]);
    }

    var rays = std.ArrayList(Ray).init(allocator);
    var max: u32 = 0;

    // top
    for (0..cols) |col| {
        const start_ray: Ray = .{ .pos = .{
            .x = @intCast(col),
            .y = 0,
        }, .dir = .down };

        const sum = try solve(
            start_ray,
            &rays,
            matrix.items,
            energized.items,
        );

        max = @max(max, sum);
        @memset(energized_contents, '.');
    }

    // bottom
    for (0..cols) |col| {
        const start_ray: Ray = .{ .pos = .{
            .x = @intCast(col),
            .y = @intCast(rows - 1),
        }, .dir = .up };

        const sum = try solve(
            start_ray,
            &rays,
            matrix.items,
            energized.items,
        );

        max = @max(max, sum);
        @memset(energized_contents, '.');
    }

    // left
    for (0..rows) |row| {
        const start_ray: Ray = .{ .pos = .{
            .x = 0,
            .y = @intCast(row),
        }, .dir = .right };

        const sum = try solve(
            start_ray,
            &rays,
            matrix.items,
            energized.items,
        );

        max = @max(max, sum);
        @memset(energized_contents, '.');
    }

    // right
    for (0..rows) |row| {
        const start_ray: Ray = .{ .pos = .{
            .x = @intCast(cols - 1),
            .y = @intCast(row),
        }, .dir = .left };

        const sum = try solve(
            start_ray,
            &rays,
            matrix.items,
            energized.items,
        );

        max = @max(max, sum);
        @memset(energized_contents, '.');
    }

    print("day16 part2 answer = {d}\n", .{max});
}
