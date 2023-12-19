//! --- Day 19: Aplenty ---
//! The Elves of Gear Island are thankful for your help and send you on your way. They even have a hang glider that someone stole from Desert Island; since you're already going that direction, it would help them a lot if you would use it to get down there and return it to them.
//! As you reach the bottom of the relentless avalanche of machine parts, you discover that they're already forming a formidable heap. Don't worry, though - a group of Elves is already here organizing the parts, and they have a system.
//! To start, each part is rated in each of four categories:
//!
//! x: Extremely cool looking
//! m: Musical (it makes a noise when you hit it)
//! a: Aerodynamic
//! s: Shiny
//!
//! Then, each part is sent through a series of workflows that will ultimately accept or reject the part. Each workflow has a name and contains a list of rules; each rule specifies a condition and where to send the part if the condition is true. The first rule that matches the part being considered is applied immediately, and the part moves on to the destination described by the rule. (The last rule in each workflow has no condition and always applies if reached.)
//! Consider the workflow ex{x>10:one,m<20:two,a>30:R,A}. This workflow is named ex and contains four rules. If workflow ex were considering a specific part, it would perform the following steps in order:
//!
//! Rule "x>10:one": If the part's x is more than 10, send the part to the workflow named one.
//! Rule "m<20:two": Otherwise, if the part's m is less than 20, send the part to the workflow named two.
//! Rule "a>30:R": Otherwise, if the part's a is more than 30, the part is immediately rejected (R).
//! Rule "A": Otherwise, because no other rules matched the part, the part is immediately accepted (A).
//!
//! If a part is sent to another workflow, it immediately switches to the start of that workflow instead and never returns. If a part is accepted (sent to A) or rejected (sent to R), the part immediately stops any further processing.
//! The system works, but it's not keeping up with the torrent of weird metal shapes. The Elves ask if you can help sort a few parts and give you the list of workflows and some part ratings (your puzzle input). For example:
//!
//! px{a<2006:qkq,m>2090:A,rfg}
//! pv{a>1716:R,A}
//! lnx{m>1548:A,A}
//! rfg{s<537:gd,x>2440:R,A}
//! qs{s>3448:A,lnx}
//! qkq{x<1416:A,crn}
//! crn{x>2662:A,R}
//! in{s<1351:px,qqz}
//! qqz{s>2770:qs,m<1801:hdj,R}
//! gd{a>3333:R,R}
//! hdj{m>838:A,pv}
//!
//! {x=787,m=2655,a=1222,s=2876}
//! {x=1679,m=44,a=2067,s=496}
//! {x=2036,m=264,a=79,s=2244}
//! {x=2461,m=1339,a=466,s=291}
//! {x=2127,m=1623,a=2188,s=1013}
//!
//! The workflows are listed first, followed by a blank line, then the ratings of the parts the Elves would like you to sort. All parts begin in the workflow named in. In this example, the five listed parts go through the following workflows:
//!
//! {x=787,m=2655,a=1222,s=2876}: in -> qqz -> qs -> lnx -> A
//! {x=1679,m=44,a=2067,s=496}: in -> px -> rfg -> gd -> R
//! {x=2036,m=264,a=79,s=2244}: in -> qqz -> hdj -> pv -> A
//! {x=2461,m=1339,a=466,s=291}: in -> px -> qkq -> crn -> R
//! {x=2127,m=1623,a=2188,s=1013}: in -> px -> rfg -> A
//!
//! Ultimately, three parts are accepted. Adding up the x, m, a, and s rating for each of the accepted parts gives 7540 for the part with x=787, 4623 for the part with x=2036, and 6951 for the part with x=2127. Adding all of the ratings for all of the accepted parts gives the sum total of 19114.
//! Sort through all of the parts you've been given; what do you get if you add together all of the rating numbers for all of the parts that ultimately get accepted?
//!
//! --- Part Two ---
//! Even with your help, the sorting process still isn't fast enough.
//! One of the Elves comes up with a new plan: rather than sort parts individually through all of these workflows, maybe you can figure out in advance which combinations of ratings will be accepted or rejected.
//! Each of the four ratings (x, m, a, s) can have an integer value ranging from a minimum of 1 to a maximum of 4000. Of all possible distinct combinations of ratings, your job is to figure out which ones will be accepted.
//! In the above example, there are 167409079868000 distinct combinations of ratings that will be accepted.
//! Consider only your list of workflows; the list of part ratings that the Elves wanted you to sort is no longer relevant. How many distinct combinations of ratings will be accepted by the Elves' workflows?

const std = @import("std");
const print = std.debug.print;

const Operation = enum { gt, lt };
const Rule = struct {
    category: u8,
    operation: Operation,
    value: u32,
    outcome: []const u8,
};

const Workflow = struct {
    rules: []Rule = undefined,
    default: []const u8 = undefined,

    pub fn parse(allocator: std.mem.Allocator, str: []const u8) !Workflow {
        var comma_it = std.mem.splitScalar(u8, str[1 .. str.len - 1], ',');
        var workflow: Workflow = .{};
        var rules = std.ArrayList(Rule).init(allocator);

        while (comma_it.next()) |token| {
            var colon_it = std.mem.splitScalar(u8, token, ':');
            const s1 = colon_it.next().?;
            const s2 = colon_it.next();

            if (s2 == null) {
                workflow.default = s1;
                break;
            }

            const outcome = s2.?;
            const value = try std.fmt.parseInt(u32, s1[2..], 10);
            const category = s1[0];
            const operation: Operation = switch (s1[1]) {
                '<' => .lt,
                '>' => .gt,
                else => unreachable,
            };

            const rule: Rule = .{
                .category = category,
                .operation = operation,
                .value = value,
                .outcome = outcome,
            };

            try rules.append(rule);
        }

        workflow.rules = try rules.toOwnedSlice();
        return workflow;
    }
};

const Part = struct {
    x: u32,
    m: u32,
    a: u32,
    s: u32,

    pub fn parse(str: []const u8) !Part {
        var comma_it = std.mem.splitScalar(u8, str[1 .. str.len - 1], ',');
        return .{
            .x = try std.fmt.parseInt(u32, comma_it.next().?[2..], 10),
            .m = try std.fmt.parseInt(u32, comma_it.next().?[2..], 10),
            .a = try std.fmt.parseInt(u32, comma_it.next().?[2..], 10),
            .s = try std.fmt.parseInt(u32, comma_it.next().?[2..], 10),
        };
    }

    pub fn rating(self: Part) u32 {
        return self.x + self.m + self.a + self.s;
    }

    pub fn outcome(self: Part, workflow: Workflow) []const u8 {
        for (workflow.rules) |rule| {
            const value: u32 = switch (rule.category) {
                'x' => self.x,
                'm' => self.m,
                'a' => self.a,
                's' => self.s,
                else => unreachable,
            };

            const expr = switch (rule.operation) {
                .gt => value > rule.value,
                .lt => value < rule.value,
            };

            if (expr) {
                return rule.outcome;
            }
        }

        return workflow.default;
    }

    pub fn applyWorflows(self: Part, workflows: std.StringHashMap(Workflow)) !bool {
        var workflow = workflows.get("in").?;

        while (true) {
            const out = self.outcome(workflow);
            if (std.mem.eql(u8, out, "A")) {
                return true;
            } else if (std.mem.eql(u8, out, "R")) {
                return false;
            } else {
                workflow = workflows.get(out).?;
            }
        }
    }
};

fn intersectMutate(a: []u64, b: []const u64) void {
    a[0] = @max(a[0], b[0]);
    a[1] = @min(a[1], b[1]);
    if (a[0] > a[1]) {
        a[0] = 0;
        a[1] = 0;
    }
}

fn countAccepted(
    outcome: []const u8,
    intervals: []const u64,
    workflows: *const std.StringHashMap(Workflow),
) u64 {
    if (std.mem.eql(u8, outcome, "A"))
        return (intervals[1] - intervals[0] + 1) *
            (intervals[3] - intervals[2] + 1) *
            (intervals[5] - intervals[4] + 1) *
            (intervals[7] - intervals[6] + 1);

    if (std.mem.eql(u8, outcome, "R"))
        return 0;

    var sum: u64 = 0;
    const workflow = workflows.get(outcome).?;
    var intervs: [8]u64 = undefined;
    std.mem.copy(u64, &intervs, intervals);

    for (workflow.rules) |rule| {
        const index: usize = switch (rule.category) {
            'x' => 0,
            'm' => 2,
            'a' => 4,
            's' => 6,
            else => unreachable,
        };

        const old: [2]u64 = .{ intervs[index], intervs[index + 1] };
        const new: [2]u64 = switch (rule.operation) {
            .lt => .{ 0, rule.value - 1 },
            .gt => .{ rule.value + 1, 4000 },
        };

        intersectMutate(intervs[index .. index + 2], &new);
        sum += countAccepted(rule.outcome, &intervs, workflows);

        intervs[index] = old[0];
        intervs[index + 1] = old[1];

        const rev: [2]u64 = switch (rule.operation) {
            .gt => .{ 0, rule.value },
            .lt => .{ rule.value, 4000 },
        };
        intersectMutate(intervs[index .. index + 2], &rev);
    }
    sum += countAccepted(workflow.default, &intervs, workflows);
    return sum;
}

pub fn part1() !void {
    var arena_instance = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_instance.deinit();
    const allocator = arena_instance.allocator();

    const file = try std.fs.cwd().openFile("input/day19.in", .{});
    defer file.close();

    const file_contents = try file.readToEndAlloc(allocator, 10 * 4096);
    var line_it = std.mem.tokenizeSequence(u8, file_contents, "\r\n");

    var workflows = std.StringHashMap(Workflow).init(allocator);
    var parts = std.ArrayList(Part).init(allocator);
    while (line_it.next()) |line| {
        if (line[0] == '{') {
            try parts.append(try Part.parse(line));
        } else {
            const start = std.mem.indexOfScalar(u8, line, '{').?;
            try workflows.put(
                line[0..start],
                try Workflow.parse(allocator, line[start..]),
            );
        }
    }

    var sum: u32 = 0;
    for (parts.items) |part| {
        if (try part.applyWorflows(workflows)) {
            sum += part.rating();
        }
    }

    print("day19 part1 answer = {d}\n", .{sum});
}

pub fn part2() !void {
    var arena_instance = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_instance.deinit();
    const allocator = arena_instance.allocator();

    const file = try std.fs.cwd().openFile("input/day19.in", .{});
    defer file.close();

    const file_contents = try file.readToEndAlloc(allocator, 10 * 4096);
    var line_it = std.mem.tokenizeSequence(u8, file_contents, "\r\n");

    var workflows = std.StringHashMap(Workflow).init(allocator);
    while (line_it.next()) |line| {
        if (line[0] == '{')
            break;

        const start = std.mem.indexOfScalar(u8, line, '{').?;
        try workflows.put(
            line[0..start],
            try Workflow.parse(allocator, line[start..]),
        );
    }

    const intervals = [_]u64{ 1, 4000 } ** 4;
    const sum = countAccepted("in", &intervals, &workflows);

    print("day19 part2 answer = {d}\n", .{sum});
}
