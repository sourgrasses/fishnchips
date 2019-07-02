pub const ParseError = error{};

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
    SYS: void,
    JP: u12,
    CALL: u12,
    SE_VX_NN: RegOperand,
    SNE_VX_NN: RegOperand,
    SE_VX_VY,
    LD_VX_NN: RegOperand,
    ADD_VX_NN: RegOperand,
    LD_VX_VY_OP,
    SNE_VX_VY,
    LD_I_NNN,
    JP_V0_NNN,
    RND_VX_NN: RegOperand,
    DRW_VX_VY_N,
    SKP_VX,
    LD_VX,
};

pub const RegOperand = struct {
    Reg: u4,
    Val: u8,
};

pub const Disasm = struct {
    pub fn parse(op: []const u8) Op {}
};
