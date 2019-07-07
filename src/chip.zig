const std = @import("std");
const fs = std.fs;
const io = std.io;
const mem = @import("mem.zig");

const Allocator = std.mem.Allocator;
const Cpu = @import("cpu.zig").Cpu;
const Disasm = @import("disasm.zig").Disasm;
const File = @import("std").fs.File;

pub const Chip8 = struct {
    allocator: *Allocator,
    cpu: *Cpu,
    ram: []u8,

    pub fn new(allocator: *Allocator) !Chip8 {
        return Chip8{
            .allocator = allocator,
            .cpu = &Cpu.new(),
            // put the RAM on the heap
            .ram = try allocator.alloc(u8, 4096),
        };
    }

    pub fn run_rom(self: Chip8, filename: []const u8) !void {
        // just read the whole file into memory since these roms are *tiny*
        const rom = try io.readFileAlloc(self.allocator, filename);

        var chunks = mem.chunks(rom, 2);

        while (chunks.next()) |chunk| {
            const op = try Disasm.parse(chunk);
            self.cpu.cycle(op);
            std.debug.warn("{X}\n", self.cpu);
        }
    }
};
