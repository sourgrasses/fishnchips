const std = @import("std");

pub fn chunks(buf: []const u8, chunk_size: usize) ChunkIterator {
    return ChunkIterator{
        .buf = buf,
        .index = 0,
        .chunk_size = chunk_size,
    };
}

/// Iterator over 'chunks' of a slice of bytes, similar to Rust's
/// [chunks](https://doc.rust-lang.org/std/slice/struct.Chunks.html) iterator
pub const ChunkIterator = struct {
    buf: []const u8,
    index: usize,
    chunk_size: usize,

    pub fn next(self: *ChunkIterator) ?[]const u8 {
        if (self.buf[self.index..].len == 0) {
            return null;
        } else if (self.buf[self.index..].len < self.chunk_size) {
            self.index = self.buf.len;
            return self.rest();
        } else {
            const slice = self.buf[self.index .. self.index + 2];
            self.index += 2;

            return slice;
        }
    }

    pub fn rest(self: ChunkIterator) []const u8 {
        return self.buf[self.index..];
    }
};
