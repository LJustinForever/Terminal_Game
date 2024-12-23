package main

import "core:fmt"
import "core:os"
import SDL "vendor:sdl2"

//These constants are used in game.odin
SDL_FLAGS :: SDL.INIT_EVERYTHING
WINDOW_FLAGS :: SDL.WINDOW_SHOWN
RENDER_FLAGS :: SDL.RENDERER_ACCELERATED

WINDOW_TITLE :: "Terminal Game"
SCREEN_WIDTH :: 800
SCREEN_HEIGHT :: 600
//

main :: proc() {
    game: Game
    defer os.exit(0)

    if !initialise(&game){
        return
    }

    game_run(&game)
    game_cleanup(&game)
}