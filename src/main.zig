const std = @import("std");

const Allocator = std.mem.Allocator;
const Chip8 = @import("chip.zig").Chip8;
const gfx = @import("gfx.zig");

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.direct_allocator);
    defer arena.deinit();

    const allocator = &arena.allocator;

    var chip = try Chip8.new(allocator);
    const res = chip.run_rom("pong.ch8");

    std.debug.warn("{}\n", res);
}
