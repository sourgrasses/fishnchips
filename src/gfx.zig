pub const DispError = error{SdlInitError};

const c = @cImport(@cInclude("SDL2/SDL.h"));

pub const Display = struct {
    renderer: ?*c.SDL_Renderer,
    win: ?*c.SDL_Window,

    pub fn new() !Display {
        if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
            return DispError.SdlInitError;
        }
        defer c.SDL_Quit();

        const win = c.SDL_CreateWindow(c"fishnchips", 100, 100, 640, 320, c.SDL_WINDOW_SHOWN);
        const renderer = c.SDL_CreateRenderer(win, -1, c.SDL_RENDERER_ACCELERATED | c.SDL_RENDERER_PRESENTVSYNC);

        _ = c.SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
        _ = c.SDL_RenderFillRect(renderer, null);
        _ = c.SDL_RenderPresent(renderer);

        return Display{
            .win = win,
            .renderer = renderer,
        };
    }

    pub fn clear(self: *Display) void {
        _ = c.SDL_SetRenderDrawColor(self.renderer, 0, 0, 0, 255);
        _ = c.SDL_RenderFillRect(self.renderer, null);
        _ = c.SDL_RenderPresent(self.renderer);
    }

    pub fn draw_sprite(self: *Display, sprite: Sprite, x: u8, y: u8) void {
        _ = c.SDL_SetRenderDrawColor(self.renderer, 255, 191, 0, 255);
        var rect = c.SDL_Rect{
            .x = x,
            .y = y,
            .w = 10,
            .h = 10,
        };

        for ([_]u8{ 0, 1, 2, 3, 4 }) |row| {
            for ([_]u8{ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 }) |bit| {
                if ((@bitReverse(u8, sprite[row]) >> bit) & 0x01 == 0x01) {
                    rect.x += bit * 10;
                    rect.y += row * 10;
                    _ = c.SDL_RenderFillRect(renderer, rect);
                }
            }
        }
        _ = c.SDL_RenderPresent(renderer);
    }
};

pub const Sprite = struct {
    pub const Zero = [_]u8{ 0xF0, 0x90, 0x90, 0x90, 0xF0 };
    pub const One = [_]u8{ 0x20, 0x60, 0x20, 0x20, 0x70 };
    pub const Two = [_]u8{ 0xF0, 0x10, 0xF0, 0x80, 0xF0 };
    pub const Three = [_]u8{ 0xF0, 0x10, 0xF0, 0x10, 0xF0 };
    pub const Four = [_]u8{ 0x90, 0x90, 0xF0, 0x10, 0x10 };
    pub const Five = [_]u8{ 0xF0, 0x80, 0xF0, 0x10, 0xF0 };
    pub const Six = [_]u8{ 0xF0, 0x80, 0xF0, 0x90, 0xF0 };
    pub const Seven = [_]u8{ 0xF0, 0x10, 0x20, 0x40, 0x40 };
    pub const Eight = [_]u8{ 0xF0, 0x90, 0xF0, 0x90, 0xF0 };
    pub const Nine = [_]u8{ 0xF0, 0x90, 0xF0, 0x10, 0xF0 };
    pub const A = [_]u8{ 0xF0, 0x90, 0xF0, 0x90, 0x90 };
    pub const B = [_]u8{ 0xE0, 0x90, 0xE0, 0x90, 0xE0 };
    pub const C = [_]u8{ 0xF0, 0x80, 0x80, 0x80, 0xF0 };
    pub const D = [_]u8{ 0xE0, 0x90, 0x90, 0x90, 0xE0 };
    pub const E = [_]u8{ 0xF0, 0x80, 0xF0, 0x80, 0xF0 };
    pub const F = [_]u8{ 0xF0, 0x80, 0xF0, 0x80, 0x80 };
};
