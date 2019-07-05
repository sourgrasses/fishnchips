pub const ParseError = error{
    InvalidOpcode,
    InvalidArg,
};

pub const OpcodeTag = enum(u4) {
    // SYS, CLS, or RET depending on low nibble and a half
    SYS = 0x0,
    // 0x1nnn, operand is address
    JP = 0x1,
    // 0x2nnn, operand is address
    CALL = 0x2,
    // 0x3xnn, skip if Vx == nn
    SE_VX_NN = 0x3,
    // 0x4xnn, skip if Vx != nn
    SNE_VX_NN = 0x4,
    // 0x5xy0, skip if Vx == Vy
    SE_VX_VY = 0x5,
    // 0x6xnn, load nn into Vx
    LD_VX_NN = 0x6,
    // 0x7xnn, add nn to Vx and store in Vx
    ADD_VX_NN = 0x7,
    // 0x8xyn, store Vy in Vx after performing operation specified in n
    LD_VX_VY_OP = 0x8,
    // 0x9xy0, skip if Vx != Vy
    SNE_VX_VY = 0x9,
    // 0xannn, load nnn into I register
    LD_I_NNN = 0xa,
    // 0xbnnn, set PC to V0 + nnn
    JP_V0_NNN = 0xb,
    // 0xcxnn, generate random byte, AND with nn, load into Vx
    RND_VX_NN = 0xc,
    // 0xdxyn, load sprite of n-bytes length at coordinates from Vx and Vy
    DRW_VX_VY_N = 0xd,
    // 0xex93/0xexa1 skip next instruction if key specified in Vx
    // is pressed/not pressed
    SKP_VX = 0xe,
    // 0xfxnn, load into or from Vx based on operation specified in nn
    LD_VX = 0xf,
};

pub const Opcode = union(OpcodeTag) {
    SYS,
    JP: u12,
    CALL: u12,
    SE_VX_NN: RegArg,
    SNE_VX_NN: RegArg,
    SE_VX_VY: RegReg,
    LD_VX_NN: RegArg,
    ADD_VX_NN: RegArg,
    LD_VX_VY_OP: RegRegArg,
    SNE_VX_VY: RegReg,
    LD_I_NNN: u12,
    JP_V0_NNN: u12,
    RND_VX_NN: RegArg,
    DRW_VX_VY_N: RegRegArg,
    SKP_VX: u4,
    LD_VX: RegArg,
};

pub const MathFn = enum {
    OR,
    AND,
    XOR,
    ADD,
    SUB,
    // If the least-significant bit of Vx is 1, then VF is set to 1, otherwise 0.
    // Then Vx is divided by 2.
    SHR,
    // If Vy > Vx, then VF is set to 1, otherwise 0. Then Vx is subtracted from Vy,
    // and the results stored in Vx.
    SUBN,
    // If the most-significant bit of Vx is 1, then VF is set to 1, otherwise to 0.
    // Then Vx is multiplied by 2.
    SHL,
};

pub const RegArg = struct {
    Reg: u4,
    Val: u8,
};

pub const RegRegArg = struct {
    RegX: u4,
    RegY: u4,
    Val: u4,
};

pub const RegReg = struct {
    RegX: u4,
    RegY: u4,
};

pub const Disasm = struct {
    pub fn parse(op: []const u8) !OpcodeTag {
        const opp = switch (op[0] >> 4) {
            @enumToInt(OpcodeTag.SYS) => Opcode.SYS,
            @enumToInt(OpcodeTag.JP) => b: {
                const arg = (@intCast(u12, op[0]) << 8) | op[1];
                break :b Opcode{ .JP = arg };
            },
            @enumToInt(OpcodeTag.CALL) => b: {
                const arg = (@intCast(u12, op[0]) << 8) | op[1];
                break :b Opcode{ .CALL = arg };
            },
            @enumToInt(OpcodeTag.SE_VX_NN) => b: {
                // mask off the high nibble and cast to 4-bit uint
                const reg = @intCast(u4, (op[0] & 0x0f));
                const arg = RegArg{ .Reg = reg, .Val = op[1] };

                break :b Opcode{ .SE_VX_NN = arg };
            },
            @enumToInt(OpcodeTag.SNE_VX_NN) => b: {
                // mask off the high nibble and cast to 4-bit uint
                const reg = @intCast(u4, (op[0] & 0x0f));
                const arg = RegArg{ .Reg = reg, .Val = op[1] };

                break :b Opcode{ .SNE_VX_NN = arg };
            },
            @enumToInt(OpcodeTag.SE_VX_VY) => b: {
                if ((op[1] & 0x0f) != 0x0) {
                    return ParseError.InvalidOpcode;
                }

                const x = @intCast(u4, (op[0] & 0x0f));
                const y = @intCast(u4, (op[1] >> 4));
                const arg = RegReg{ .RegX = x, .RegY = y };

                break :b Opcode{ .SE_VX_VY = arg };
            },
            @enumToInt(OpcodeTag.LD_VX_NN) => b: {
                const reg = @intCast(u4, (op[0] & 0x0f));
                const arg = RegArg{ .Reg = reg, .Val = op[1] };

                break :b Opcode{ .LD_VX_NN = arg };
            },
            @enumToInt(OpcodeTag.ADD_VX_NN) => b: {
                const reg = @intCast(u4, (op[0] & 0x0f));
                const arg = RegArg{ .Reg = reg, .Val = op[1] };

                break :b Opcode{ .ADD_VX_NN = arg };
            },
            @enumToInt(OpcodeTag.LD_VX_VY_OP) => b: {
                const x = @intCast(u4, (op[0] & 0x0f));
                const y = @intCast(u4, (op[1] >> 4));
                const n = @intCast(u4, (op[1] & 0x0f));
                const arg = RegRegArg{ .RegX = x, .RegY = y, .Val = n };

                break :b Opcode{ .LD_VX_VY_OP = arg };
            },
            @enumToInt(OpcodeTag.SNE_VX_VY) => b: {
                if ((op[1] & 0x0f) != 0x0) {
                    return ParseError.InvalidOpcode;
                }

                const x = @intCast(u4, (op[0] & 0x0f));
                const y = @intCast(u4, (op[1] >> 4));
                const arg = RegReg{ .RegX = x, .RegY = y };

                break :b Opcode{ .SNE_VX_VY = arg };
            },
            @enumToInt(OpcodeTag.LD_I_NNN) => b: {
                const arg = (@intCast(u12, op[0]) << 8) | op[1];
                break :b Opcode{ .LD_I_NNN = arg };
            },
            @enumToInt(OpcodeTag.JP_V0_NNN) => b: {
                const arg = (@intCast(u12, op[0]) << 8) | op[1];
                break :b Opcode{ .JP_V0_NNN = arg };
            },
            @enumToInt(OpcodeTag.RND_VX_NN) => b: {
                const reg = @intCast(u4, (op[0] & 0x0f));
                const arg = RegArg{ .Reg = reg, .Val = op[1] };

                break :b Opcode{ .RND_VX_NN = arg };
            },
            @enumToInt(OpcodeTag.DRW_VX_VY_N) => b: {
                const x = @intCast(u4, (op[0] & 0x0f));
                const y = @intCast(u4, (op[1] >> 4));
                const n = @intCast(u4, (op[1] & 0x0f));
                const arg = RegRegArg{ .RegX = x, .RegY = y, .Val = n };

                break :b Opcode{ .DRW_VX_VY_N = arg };
            },
            @enumToInt(OpcodeTag.SKP_VX) => b: {
                if (op[1] != 0x93 and op[1] != 0xa1) {
                    return ParseError.InvalidOpcode;
                }

                break :b Opcode{ .SKP_VX = @intCast(u4, (op[0] & 0x0f)) };
            },
            @enumToInt(OpcodeTag.LD_VX) => b: {
                const reg = @intCast(u4, (op[0] & 0x0f));
                const arg = RegArg{ .Reg = reg, .Val = op[1] };

                break :b Opcode{ .LD_VX = arg };
            },
            else => {
                return ParseError.InvalidOpcode;
            },
        };

        return opp;
    }
};
