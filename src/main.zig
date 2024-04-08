const std = @import("std");

const c = @import("c.zig");

const TICKS = 30;

pub fn main() !void {
    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    }
    defer c.SDL_Quit();

    const screen = c.SDL_CreateWindow("My Game Window", c.SDL_WINDOWPOS_UNDEFINED, c.SDL_WINDOWPOS_UNDEFINED, 400, 140, c.SDL_WINDOW_OPENGL) orelse
        {
        c.SDL_Log("Unable to create window: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyWindow(screen);

    const renderer = c.SDL_CreateRenderer(screen, -1, 0) orelse {
        c.SDL_Log("Unable to create renderer: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyRenderer(renderer);

    const interval = 1000 / TICKS;

    var quit = false;

    while (!quit) {
        const t1 = c.SDL_GetTicks();

        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                c.SDL_QUIT => quit = true,
                c.SDL_KEYDOWN => {
                    if (c.SDLK_ESCAPE == event.key.keysym.sym) quit = true;
                },
                else => {},
            }
        }

        _ = c.SDL_RenderClear(renderer);
        c.SDL_RenderPresent(renderer);

        const t2 = c.SDL_GetTicks();
        const elapsed = t2 - t1;
        if (elapsed < interval) {
            c.SDL_Delay(interval - elapsed);
        }
    }
}
