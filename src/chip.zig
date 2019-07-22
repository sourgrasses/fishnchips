const std = @import("std");
const fs = std.fs;
const io = std.io;
const mem = @import("mem.zig");

const Allocator = std.mem.Allocator;
const Cpu = @import("cpu.zig").Cpu;
const Disasm = @import("disasm.zig").Disasm;
const Display = @import("gfx.zig").Display;
const File = @import("std").fs.File;

pub const Chip8 = struct {
    allocator: *Allocator,
    disp: Display,
    ram: []u8,
    cpu: Cpu,

    pub fn new(allocator: *Allocator) !Chip8 {
        var disp = try Display.new();
        var ram = try allocator.alloc(u8, 4096);

        return Chip8{
            .allocator = allocator,
            .disp = disp,
            // put the RAM on the heap
            .ram = ram,
            .cpu = Cpu.new(&disp, ram),
        };
    }

    pub fn run_rom(self: *Chip8, filename: []const u8) !void {
        // just read the whole file into memory since these roms are *tiny*
        const rom = try io.readFileAlloc(self.allocator, filename);
        std.debug.warn("{} bytes\n", rom.len);

        while (true) {
            const op = try Disasm.parse(rom[(self.cpu.pc - 0x0200)..]);
            std.debug.warn("{}\n", op);
            self.cpu.cycle(op);
            self.disp.render();
        }
    }
};
