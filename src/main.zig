const day1 = @import("day1.zig");
const day2 = @import("day2.zig");
const day3 = @import("day3.zig");
const day4 = @import("day4.zig");
const day5 = @import("day5.zig");
const day6 = @import("day6.zig");
const day7 = @import("day7.zig");
const day8 = @import("day8.zig");
const day9 = @import("day9.zig");
const day10 = @import("day10.zig");
const day11 = @import("day11.zig");

pub fn main() !void {
    try day1.part1();
    try day1.part2();

    try day2.part1();
    try day2.part2();

    try day3.part1();
    try day3.part2();

    try day4.part1();
    try day4.part2();

    try day5.part1();
    try day5.part2();

    try day6.part1();
    try day6.part2();

    try day7.part1();
    try day7.part2();

    try day8.part1();
    try day8.part2();

    try day9.part1();
    try day9.part2();

    try day10.part1();
    try day10.part2();

    try day11.part1();
    try day11.part2();
}
