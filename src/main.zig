const cpu = @import("cpu.zig");
const gfx = @import("gfx.zig");
const std = @import("std");

pub fn main() anyerror!void {
    var icpu = cpu.Cpu.new();
    icpu.cycle();
}
