//! --- Day 14: Parabolic Reflector Dish ---
//! You reach the place where all of the mirrors were pointing: a massive parabolic reflector dish attached to the side of another large mountain.
//! The dish is made up of many small mirrors, but while the mirrors themselves are roughly in the shape of a parabolic reflector dish, each individual mirror seems to be pointing in slightly the wrong direction. If the dish is meant to focus light, all it's doing right now is sending it in a vague direction.
//! This system must be what provides the energy for the lava! If you focus the reflector dish, maybe you can go where it's pointing and use the light to fix the lava production.
//! Upon closer inspection, the individual mirrors each appear to be connected via an elaborate system of ropes and pulleys to a large metal platform below the dish. The platform is covered in large rocks of various shapes. Depending on their position, the weight of the rocks deforms the platform, and the shape of the platform controls which ropes move and ultimately the focus of the dish.
//! In short: if you move the rocks, you can focus the dish. The platform even has a control panel on the side that lets you tilt it in one of four directions! The rounded rocks (O) will roll when the platform is tilted, while the cube-shaped rocks (#) will stay in place. You note the positions of all of the empty spaces (.) and rocks (your puzzle input). For example:
//!
//! O....#....
//! O.OO#....#
//! .....##...
//! OO.#O....O
//! .O.....O#.
//! O.#..O.#.#
//! ..O..#O..O
//! .......O..
//! #....###..
//! #OO..#....
//!
//! Start by tilting the lever so all of the rocks will slide north as far as they will go:
//!
//! OOOO.#.O..
//! OO..#....#
//! OO..O##..O
//! O..#.OO...
//! ........#.
//! ..#....#.#
//! ..O..#.O.O
//! ..O.......
//! #....###..
//! #....#....
//!
//! You notice that the support beams along the north side of the platform are damaged; to ensure the platform doesn't collapse, you should calculate the total load on the north support beams.
//! The amount of load caused by a single rounded rock (O) is equal to the number of rows from the rock to the south edge of the platform, including the row the rock is on. (Cube-shaped rocks (#) don't contribute to load.) So, the amount of load caused by each rock in each row is as follows:
//!
//! OOOO.#.O.. 10
//! OO..#....#  9
//! OO..O##..O  8
//! O..#.OO...  7
//! ........#.  6
//! ..#....#.#  5
//! ..O..#.O.O  4
//! ..O.......  3
//! #....###..  2
//! #....#....  1
//!
//! The total load is the sum of the load caused by all of the rounded rocks. In this example, the total load is 136.
//! Tilt the platform so that the rounded rocks all roll north. Afterward, what is the total load on the north support beams?
//!
//! --- Part Two ---
//! The parabolic reflector dish deforms, but not in a way that focuses the beam. To do that, you'll need to move the rocks to the edges of the platform. Fortunately, a button on the side of the control panel labeled "spin cycle" attempts to do just that!
//! Each cycle tilts the platform four times so that the rounded rocks roll north, then west, then south, then east. After each tilt, the rounded rocks roll as far as they can before the platform tilts in the next direction. After one cycle, the platform will have finished rolling the rounded rocks in those four directions in that order.
//! Here's what happens in the example above after each of the first few cycles:
//!
//! After 1 cycle:
//! .....#....
//! ....#...O#
//! ...OO##...
//! .OO#......
//! .....OOO#.
//! .O#...O#.#
//! ....O#....
//! ......OOOO
//! #...O###..
//! #..OO#....
//!
//! After 2 cycles:
//! .....#....
//! ....#...O#
//! .....##...
//! ..O#......
//! .....OOO#.
//! .O#...O#.#
//! ....O#...O
//! .......OOO
//! #..OO###..
//! #.OOO#...O
//!
//! After 3 cycles:
//! .....#....
//! ....#...O#
//! .....##...
//! ..O#......
//! .....OOO#.
//! .O#...O#.#
//! ....O#...O
//! .......OOO
//! #...O###.O
//! #.OOO#...O
//!
//! This process should work if you leave it running long enough, but you're still worried about the north support beams. To make sure they'll survive for a while, you need to calculate the total load on the north support beams after 1000000000 cycles.
//! In the above example, after 1000000000 cycles, the total load on the north support beams is 64.
//! Run the spin cycle for 1000000000 cycles. Afterward, what is the total load on the north support beams?

const std = @import("std");
const print = std.debug.print;

fn tiltNorth(matrix: std.ArrayList([]u8)) void {
    for (matrix.items[1..], 1..) |row, i| {
        for (row, 0..) |value, j| {
            if (value == 'O') {
                var ii: i32 = @intCast(i - 1);
                while (ii >= 0 and matrix.items[@intCast(ii)][j] == '.') : (ii -= 1) {}

                matrix.items[i][j] = '.';
                matrix.items[@intCast(ii + 1)][j] = 'O';
            }
        }
    }
}

fn tiltEast(matrix: std.ArrayList([]u8)) void {
    const cols = matrix.items[0].len;
    var j: i32 = @intCast(cols - 2);

    while (j >= 0) : (j -= 1) {
        for (0..matrix.items.len) |i| {
            const value = matrix.items[i][@intCast(j)];
            if (value == 'O') {
                var jj: usize = @intCast(j + 1);
                while (jj < cols and matrix.items[i][jj] == '.') : (jj += 1) {}

                matrix.items[i][@intCast(j)] = '.';
                matrix.items[i][jj - 1] = 'O';
            }
        }
    }
}

fn tiltSouth(matrix: std.ArrayList([]u8)) void {
    const rows = matrix.items.len;
    var i: i32 = @intCast(rows - 2);

    while (i >= 0) : (i -= 1) {
        for (matrix.items[@intCast(i)], 0..) |value, j| {
            if (value == 'O') {
                var ii: usize = @intCast(i + 1);
                while (ii < rows and matrix.items[ii][j] == '.') : (ii += 1) {}

                matrix.items[@intCast(i)][j] = '.';
                matrix.items[ii - 1][j] = 'O';
            }
        }
    }
}

fn tiltWest(matrix: std.ArrayList([]u8)) void {
    const cols = matrix.items[0].len;

    for (1..cols) |j| {
        for (0..matrix.items.len) |i| {
            const value = matrix.items[i][j];
            if (value == 'O') {
                var jj: i32 = @intCast(j - 1);
                while (jj >= 0 and matrix.items[i][@intCast(jj)] == '.') : (jj -= 1) {}

                matrix.items[i][j] = '.';
                matrix.items[i][@intCast(jj + 1)] = 'O';
            }
        }
    }
}

fn spin(matrix: std.ArrayList([]u8)) void {
    tiltNorth(matrix);
    tiltWest(matrix);
    tiltSouth(matrix);
    tiltEast(matrix);
}

fn loadNorth(matrix: std.ArrayList([]u8)) u64 {
    var sum: u64 = 0;
    for (matrix.items, 0..) |row, i| {
        const load = matrix.items.len - i;
        for (row) |value| {
            if (value == 'O') {
                sum += load;
            }
        }
    }
    return sum;
}

pub fn part1() !void {
    var file = try std.fs.cwd().openFile("input/day14.in", .{});
    defer file.close();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    defer arena.deinit();
    const allocator = arena.allocator();

    const file_contents = try file.readToEndAlloc(allocator, 10 * 4096);
    var line_it = std.mem.tokenizeSequence(u8, file_contents, "\r\n");

    var matrix = std.ArrayList([]u8).init(allocator);
    while (line_it.next()) |line| {
        try matrix.append(@constCast(line));
    }
    tiltNorth(matrix);

    print("day14 part1 answer = {d}\n", .{loadNorth(matrix)});
}

pub fn part2() !void {
    var file = try std.fs.cwd().openFile("input/day14.in", .{});
    defer file.close();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    defer arena.deinit();
    const allocator = arena.allocator();

    const file_contents = try file.readToEndAlloc(allocator, 10 * 4096);
    var line_it = std.mem.tokenizeSequence(u8, file_contents, "\r\n");

    var matrix = std.ArrayList([]u8).init(allocator);
    while (line_it.next()) |line| {
        try matrix.append(@constCast(line));
    }

    // wait until the loop begins
    const initial_cycles = 120;
    for (0..initial_cycles) |_| {
        spin(matrix);
    }

    // determine period of loop
    // !!! may be wrong if a value repeats inside the loop
    // !!! in that case tweak the initial_cycles
    const load = loadNorth(matrix);
    var next_load: u64 = 0;
    var period: u32 = 0;
    while (load != next_load) : (period += 1) {
        spin(matrix);
        next_load = loadNorth(matrix);
    }

    // calculate offset
    const cycles = 1_000_000_000 - initial_cycles;
    const offset = cycles % period;

    // spin until offset is 0
    for (0..offset) |_| {
        spin(matrix);
    }

    print("day14 part1 answer = {d}\n", .{loadNorth(matrix)});
}
