const day1 = @import("day1.zig");
const day2 = @import("day2.zig");
const day3 = @import("day3.zig");
const day4 = @import("day4.zig");

pub fn main() !void {
    try day1.part1();
    try day1.part2();

    try day2.part1();
    try day2.part2();

    try day3.part1();
    try day3.part2();

    try day4.part1();
    try day4.part2();
}
