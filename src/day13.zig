//! --- Day 13: Point of Incidence ---
//! With your help, the hot springs team locates an appropriate spring which launches you neatly and precisely up to the edge of Lava Island.
//! There's just one problem: you don't see any lava.
//! You do see a lot of ash and igneous rock; there are even what look like gray mountains scattered around. After a while, you make your way to a nearby cluster of mountains only to discover that the valley between them is completely full of large mirrors. Most of the mirrors seem to be aligned in a consistent way; perhaps you should head in that direction?
//! As you move through the valley of mirrors, you find that several of them have fallen from the large metal frames keeping them in place. The mirrors are extremely flat and shiny, and many of the fallen mirrors have lodged into the ash at strange angles. Because the terrain is all one color, it's hard to tell where it's safe to walk or where you're about to run into a mirror.
//! You note down the patterns of ash (.) and rocks (#) that you see as you walk (your puzzle input); perhaps by carefully analyzing these patterns, you can figure out where the mirrors are!
//! For example:
//!
//! #.##..##.
//! ..#.##.#.
//! ##......#
//! ##......#
//! ..#.##.#.
//! ..##..##.
//! #.#.##.#.
//!
//! #...##..#
//! #....#..#
//! ..##..###
//! #####.##.
//! #####.##.
//! ..##..###
//! #....#..#
//!
//! To find the reflection in each pattern, you need to find a perfect reflection across either a horizontal line between two rows or across a vertical line between two columns.
//! In the first pattern, the reflection is across a vertical line between two columns; arrows on each of the two columns point at the line between the columns:
//!
//! 123456789
//!     ><
//! #.##..##.
//! ..#.##.#.
//! ##......#
//! ##......#
//! ..#.##.#.
//! ..##..##.
//! #.#.##.#.
//!     ><
//! 123456789
//!
//! In this pattern, the line of reflection is the vertical line between columns 5 and 6. Because the vertical line is not perfectly in the middle of the pattern, part of the pattern (column 1) has nowhere to reflect onto and can be ignored; every other column has a reflected column within the pattern and must match exactly: column 2 matches column 9, column 3 matches 8, 4 matches 7, and 5 matches 6.
//! The second pattern reflects across a horizontal line instead:
//!
//! 1 #...##..# 1
//! 2 #....#..# 2
//! 3 ..##..### 3
//! 4v#####.##.v4
//! 5^#####.##.^5
//! 6 ..##..### 6
//! 7 #....#..# 7
//!
//! This pattern reflects across the horizontal line between rows 4 and 5. Row 1 would reflect with a hypothetical row 8, but since that's not in the pattern, row 1 doesn't need to match anything. The remaining rows match: row 2 matches row 7, row 3 matches row 6, and row 4 matches row 5.
//! To summarize your pattern notes, add up the number of columns to the left of each vertical line of reflection; to that, also add 100 multiplied by the number of rows above each horizontal line of reflection. In the above example, the first pattern's vertical line has 5 columns to its left and the second pattern's horizontal line has 4 rows above it, a total of 405.
//! Find the line of reflection in each of the patterns in your notes. What number do you get after summarizing all of your notes?
//!
//! --- Part Two ---
//! You resume walking through the valley of mirrors and - SMACK! - run directly into one. Hopefully nobody was watching, because that must have been pretty embarrassing.
//! Upon closer inspection, you discover that every mirror has exactly one smudge: exactly one . or # should be the opposite type.
//! In each pattern, you'll need to locate and fix the smudge that causes a different reflection line to be valid. (The old reflection line won't necessarily continue being valid after the smudge is fixed.)
//! Here's the above example again:
//!
//! #.##..##.
//! ..#.##.#.
//! ##......#
//! ##......#
//! ..#.##.#.
//! ..##..##.
//! #.#.##.#.
//!
//! #...##..#
//! #....#..#
//! ..##..###
//! #####.##.
//! #####.##.
//! ..##..###
//! #....#..#
//!
//! The first pattern's smudge is in the top-left corner. If the top-left # were instead ., it would have a different, horizontal line of reflection:
//!
//! 1 ..##..##. 1
//! 2 ..#.##.#. 2
//! 3v##......#v3
//! 4^##......#^4
//! 5 ..#.##.#. 5
//! 6 ..##..##. 6
//! 7 #.#.##.#. 7
//!
//! With the smudge in the top-left corner repaired, a new horizontal line of reflection between rows 3 and 4 now exists. Row 7 has no corresponding reflected row and can be ignored, but every other row matches exactly: row 1 matches row 6, row 2 matches row 5, and row 3 matches row 4.
//! In the second pattern, the smudge can be fixed by changing the fifth symbol on row 2 from . to #:
//!
//! 1v#...##..#v1
//! 2^#...##..#^2
//! 3 ..##..### 3
//! 4 #####.##. 4
//! 5 #####.##. 5
//! 6 ..##..### 6
//! 7 #....#..# 7
//!
//! Now, the pattern has a different horizontal line of reflection between rows 1 and 2.
//! Summarize your notes as before, but instead use the new different reflection lines. In this example, the first pattern's new horizontal line has 3 rows above it and the second pattern's new horizontal line has 1 row above it, summarizing to the value 400.
//! In each pattern, fix the smudge and find the different line of reflection. What number do you get after summarizing the new reflection line in each pattern in your notes?

const std = @import("std");
const print = std.debug.print;
const Mat = std.ArrayList([]const u8);

fn eqlRows(matrix: Mat, row1: usize, row2: usize) bool {
    return std.mem.eql(u8, matrix.items[row1], matrix.items[row2]);
}

fn eqlCols(matrix: Mat, col1: usize, col2: usize) bool {
    for (matrix.items) |row| {
        if (row[col1] != row[col2]) return false;
    }
    return true;
}

fn isReflectionRow(matrix: Mat, row: usize) bool {
    const range = @min(row + 1, matrix.items.len - row - 1);
    for (0..range) |offset| {
        const row1 = row - offset;
        const row2 = row + offset + 1;
        if (!eqlRows(matrix, row1, row2)) return false;
    }
    return true;
}

fn isReflectionCol(matrix: Mat, col: usize) bool {
    const range = @min(col + 1, matrix.items[0].len - col - 1);
    for (0..range) |offset| {
        const col1 = col - offset;
        const col2 = col + offset + 1;
        if (!eqlCols(matrix, col1, col2)) return false;
    }
    return true;
}

fn diffRows(matrix: Mat, row1: usize, row2: usize) u32 {
    var count: u32 = 0;
    for (matrix.items[row1], matrix.items[row2]) |a, b| {
        if (a != b) count += 1;
    }
    return count;
}

fn diffCols(matrix: Mat, col1: usize, col2: usize) u32 {
    var count: u32 = 0;
    for (matrix.items) |row| {
        if (row[col1] != row[col2]) count += 1;
    }
    return count;
}

fn isSmudgedReflectionRow(matrix: Mat, row: usize) bool {
    const range = @min(row + 1, matrix.items.len - row - 1);
    var count: u32 = 0;
    for (0..range) |offset| {
        const row1 = row - offset;
        const row2 = row + offset + 1;
        count += diffRows(matrix, row1, row2);
        if (count > 1) return false;
    }
    return count == 1;
}

fn isSmudgedReflectionCol(matrix: Mat, col: usize) bool {
    const range = @min(col + 1, matrix.items[0].len - col - 1);
    var count: u32 = 0;
    for (0..range) |offset| {
        const col1 = col - offset;
        const col2 = col + offset + 1;
        count += diffCols(matrix, col1, col2);
        if (count > 1) return false;
    }
    return count == 1;
}

pub fn part1() !void {
    var file = try std.fs.cwd().openFile("input/day13.in", .{});
    defer file.close();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    defer arena.deinit();
    const allocator = arena.allocator();

    const file_contents = try file.readToEndAlloc(allocator, 10 * 4096);
    var pattern_it = std.mem.tokenizeSequence(u8, file_contents, "\r\n\r\n");

    var summary: u64 = 0;
    while (pattern_it.next()) |pattern| {
        var matrix = Mat.init(allocator);

        var line_it = std.mem.tokenizeSequence(u8, pattern, "\r\n");
        while (line_it.next()) |line| {
            try matrix.append(line);
        }

        for (0..matrix.items.len - 1) |index| {
            if (isReflectionRow(matrix, index)) {
                summary += 100 * (index + 1);
            }
        }

        for (0..matrix.items[0].len - 1) |index| {
            if (isReflectionCol(matrix, index)) {
                summary += index + 1;
            }
        }
    }

    print("day13 part1 answer = {d}\n", .{summary});
}

pub fn part2() !void {
    var file = try std.fs.cwd().openFile("input/day13.in", .{});
    defer file.close();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    defer arena.deinit();
    const allocator = arena.allocator();

    const file_contents = try file.readToEndAlloc(allocator, 10 * 4096);
    var pattern_it = std.mem.tokenizeSequence(u8, file_contents, "\r\n\r\n");

    var summary: u64 = 0;
    while (pattern_it.next()) |pattern| {
        var matrix = Mat.init(allocator);

        var line_it = std.mem.tokenizeSequence(u8, pattern, "\r\n");
        while (line_it.next()) |line| {
            try matrix.append(line);
        }

        for (0..matrix.items.len - 1) |index| {
            if (isSmudgedReflectionRow(matrix, index)) {
                summary += 100 * (index + 1);
            }
        }

        for (0..matrix.items[0].len - 1) |index| {
            if (isSmudgedReflectionCol(matrix, index)) {
                summary += index + 1;
            }
        }
    }

    print("day13 part2 answer = {d}\n", .{summary});
}
