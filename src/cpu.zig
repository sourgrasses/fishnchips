const ParseError = @import("disasm").ParseError;

const Cpu = struct {
    v0: u8,
    v1: u8,
    v2: u8,
    v3: u8,
    v4: u8,
    v5: u8,
    v6: u8,
    v7: u8,
    v8: u8,
    v9: u8,
    va: u8,
    vb: u8,
    vc: u8,
    ve: u8,
    vf: u8,

    i: u16,
    pc: u16,
    sp: u8,

    delay: u8,
    sound: u8,

    pub fn new() Cpu {
        return Cpu{
            .v0 = 0,
            .v1 = 0,
            .v2 = 0,
            .v3 = 0,
            .v4 = 0,
            .v5 = 0,
            .v6 = 0,
            .v7 = 0,
            .v8 = 0,
            .v9 = 0,
            .va = 0,
            .vb = 0,
            .vc = 0,
            .ve = 0,
            .vf = 0,

            .i = 0,
            .pc = 0,
            .sp = 0,

            .delay = 0,
            .sound = 0,
        };
    }

    pub fn cycle(self: *Cpu) ParseError {}
};
