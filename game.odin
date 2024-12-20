package main

import "core:fmt"
import SDL "vendor:sdl2"

Game :: struct{
    window: ^SDL.Window,
    renderer: ^SDL.Renderer,
    event: SDL.Event,
    texture: ^SDL.Texture
}

dst_rect : SDL.Rect
char_texture : ^SDL.Texture
initialise :: proc(g: ^Game) -> bool {
    if SDL.Init(SDL_FLAGS) != 0 {
        SDL.Log("Error initialising SDL2: %s", SDL.GetError())
        return false
    }

    g.window = SDL.CreateWindow(
    WINDOW_TITLE,
    SDL.WINDOWPOS_CENTERED,
    SDL.WINDOWPOS_CENTERED,
    SCREEN_WIDTH,
    SCREEN_HEIGHT,
    WINDOW_FLAGS)

    if g.window == nil {
        SDL.Log("Error initialising Window: %s", SDL.GetError())
        return false
    }

    g.renderer = SDL.CreateRenderer(g.window, -1, RENDER_FLAGS)
    if g.renderer == nil {
        SDL.Log("Error initialising Renderer: %s", SDL.GetError())
        return false
    }

    texture : ^SDL.Texture
    texture = load_chars_from_BMP(g.renderer)
    if texture == nil  {
        SDL.Log("Error loading ascii: %s", SDL.GetError())
        return false
    }

    chars := extract_chars_from_texture(g.renderer, texture, CHAR_WIDTH, CHAR_HEIGHT)
    if chars == nil{
        SDL.Log("Error extracting chars from texture: %s", SDL.GetError())
        return false
    }
    defer delete(chars)

    char_texture = create_texture_from_sprite(g.renderer, chars[1])
    if char_texture == nil{
        SDL.Log("Error creating texture from sprite: %s", SDL.GetError())
        return false
    }

    dst_rect = {SCREEN_WIDTH/2, SCREEN_HEIGHT/2 , i32(chars[1].width) * CHAR_SCALE, i32(chars[1].height) * CHAR_SCALE}

    return true
}

game_cleanup :: proc(g: ^Game) {
    if g != nil {
        if g.renderer != nil do SDL.DestroyRenderer(g.renderer)
        if g.window != nil do SDL.DestroyWindow(g.window)
        if g.texture != nil do SDL.DestroyTexture(g.texture)
        SDL.Quit()
    }
}

game_run :: proc(g: ^Game){
    for{
        for SDL.PollEvent(&g.event){
            #partial switch g.event.type {
                case .QUIT:
                    return
                case .KEYDOWN:
                    #partial switch g.event.key.keysym.scancode {
                    case .ESCAPE:
                        return
                    }
            }
        }

        SDL.RenderClear(g.renderer)
        //Render objects
        SDL.RenderCopy(g.renderer, char_texture, nil, &dst_rect)
        SDL.RenderPresent(g.renderer)
        SDL.Delay(16)
    }
}