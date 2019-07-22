const Display = @import("gfx.zig").Display;
const Opcode = @import("disasm.zig").Opcode;
const OpcodeTag = @import("disasm.zig").OpcodeTag;
const OpFn = @import("disasm.zig").OpFn;
const SysFn = @import("disasm.zig").SysFn;
const ParseError = disasm.ParseError;
const std = @import("std");

pub const Cpu = struct {
    v: [16]u8,

    i: u16,
    pc: u16,
    sp: u8,

    dt: u8,
    st: u8,

    disp: *Display,
    stack: [16]u16,
    ram: []u8,

    pub fn new(disp: *Display, ram: []u8) Cpu {
        return Cpu{
            .v = [_]u8{
                0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0,
            },

            .i = 0,
            .pc = 0x0200,
            .sp = 0,

            .dt = 0,
            .st = 0,

            .disp = disp,
            .stack = [_]u16{
                0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0,
            },
            .ram = ram,
        };
    }

    pub fn cycle(self: *Cpu, op: Opcode) void {
        switch (op) {
            Opcode.SYS => |top| {
                switch (top) {
                    SysFn.NOP => return,
                    SysFn.CLS => self.disp.clear(),
                    SysFn.RET => {
                        self.sp -= 1;
                        self.pc = self.stack[self.sp];
                    },
                }
            },
            Opcode.JP => |top| { // top = this op
                self.pc = @intCast(u16, top);
                return;
            },
            Opcode.CALL => |top| {
                self.stack[self.sp] = self.pc;
                self.sp += 1;
                // put the current pc on top of the stack
                self.pc = @intCast(u16, top);
                return;
            },
            Opcode.SE_VX_NN => |top| {
                if (self.v[top.Reg] == top.Val) {
                    self.pc += 2;
                }
            },
            Opcode.SNE_VX_NN => |top| {
                if (self.v[top.Reg] != top.Val) {
                    self.pc += 2;
                }
            },
            Opcode.SE_VX_VY => |top| {
                if (self.v[top.RegX] == self.v[top.RegY]) {
                    self.pc += 2;
                }
            },
            Opcode.LD_VX_NN => |top| {
                self.v[top.Reg] = top.Val;
            },
            Opcode.ADD_VX_NN => |top| {
                // let's assume for now we want this to wrap around on overflow
                self.v[top.Reg] = self.v[top.Reg] +% top.Val;
            },
            Opcode.LD_VX_VY_OP => |top| {
                switch (top.Op) {
                    OpFn.LD => {
                        self.v[top.RegX] = self.v[top.RegY];
                    },
                    OpFn.OR => {
                        self.v[top.RegX] = self.v[top.RegY] | self.v[top.RegX];
                    },
                    OpFn.AND => {
                        self.v[top.RegX] = self.v[top.RegY] & self.v[top.RegX];
                    },
                    OpFn.XOR => {
                        self.v[top.RegX] = self.v[top.RegY] ^ self.v[top.RegX];
                    },
                    OpFn.ADD => {
                        self.v[top.RegX] = self.v[top.RegY] +% self.v[top.RegX];
                    },
                    OpFn.SUB => {
                        self.v[top.RegX] = self.v[top.RegY] -% self.v[top.RegX];
                    },
                    OpFn.SHR => {
                        if (self.v[top.RegX] & 0x01 == 0x1) {
                            self.v[0xf] = 0x01;
                        } else {
                            self.v[0xf] = 0x00;
                        }

                        self.v[top.RegX] /= 2;
                    },
                    OpFn.SUBN => {
                        if (self.v[top.RegY] > self.v[top.RegX]) {
                            self.v[0xf] = 0x01;
                        } else {
                            self.v[0xf] = 0x00;
                        }

                        self.v[top.RegX] = self.v[top.RegY] -% self.v[top.RegX];
                    },
                    OpFn.SHL => {
                        if (self.v[top.RegX] & 0x01 == 0x1) {
                            self.v[0xf] = 0x01;
                        } else {
                            self.v[0xf] = 0x00;
                        }

                        self.v[top.RegX] = self.v[top.RegX] *% self.v[top.RegX];
                    },
                }
            },
            Opcode.SNE_VX_VY => |top| {
                if (self.v[top.RegX] != self.v[top.RegY]) {
                    self.pc += 2;
                }
            },
            Opcode.LD_I_NNN => |top| {
                self.i = top;
            },
            Opcode.JP_V0_NNN => |top| {
                self.pc = self.v[0x0] +% top;
                return;
            },
            Opcode.RND_VX_NN => |top| {
                // TODO: randomize rnd
                const rnd = 10;
                self.v[top.Reg] = top.Val & rnd;
            },
            Opcode.DRW_VX_VY_N => {
                // TODO: display stuff
            },
            Opcode.SKP_VX => {
                // TODO: keyboard stuff
            },
            Opcode.LD_VX => |top| {
                switch (top.Val) {
                    0x07 => {
                        self.v[top.Reg] = self.dt;
                    },
                    0x0a => {
                        // TODO: Wait for a key press, store the value of the key in Vx
                    },
                    0x15 => {
                        self.dt = self.v[top.Reg];
                    },
                    0x18 => {
                        self.st = self.v[top.Reg];
                    },
                    0x1e => {
                        self.i = self.i +% self.v[top.Reg];
                    },
                    0x29 => {
                        // TODO: sprite/display stuff
                    },
                    0x33 => {
                        // TODO: interop
                    },
                    0x55 => {
                        // TODO: interop
                    },
                    0x65 => {
                        // TODO: interop
                    },
                    else => unreachable,
                }
            },
            else => unreachable,
        }

        self.pc += 2;
    }

    pub fn show(self: Cpu) void {
        std.debug.warn("Cpu{{\n");
        for (self.v) |v, i| {
            std.debug.warn("    v[{x}]: {x}\n", i, v);
        }
        std.debug.warn("    i: {x}\n", self.i);
        std.debug.warn("    pc: {x}\n", self.pc);
        std.debug.warn("    sp: {x}\n", self.sp);
        std.debug.warn("    dt: {x}\n", self.dt);
        std.debug.warn("    st: {x}\n", self.st);
        std.debug.warn("}}\n");
    }
};
