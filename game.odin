package main

import "core:fmt"
import SDL "vendor:sdl2"

CHAR_WIDTH :: 8
CHAR_HEIGHT :: 12

Game :: struct{
    window: ^SDL.Window,
    renderer: ^SDL.Renderer,
    event: SDL.Event,
    chars: []CharacterSprite //holds all characters from bmp
}

entity_manager := EntityManager {}

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

    renderer := SDL.CreateRenderer(g.window, -1, RENDER_FLAGS)
    if renderer == nil {
        SDL.Log("Error initialising Renderer: %s", SDL.GetError())
        return false
    }

    g.renderer = renderer
    entity_manager.renderer = renderer
    entity_manager.entities = make([dynamic]Entity, 0, 30)

    bmp_texture := load_chars_from_BMP(g.renderer)
    if bmp_texture == nil  {
        SDL.Log("Error loading ascii: %s", SDL.GetError())
        return false
    }

    g.chars = extract_chars_from_texture(g.renderer, bmp_texture, CHAR_WIDTH, CHAR_HEIGHT)
    SDL.DestroyTexture(bmp_texture)
    if g.chars == nil{
        SDL.Log("Error extracting chars from texture: %s", SDL.GetError())
        return false
    }

    char_texture := create_texture_from_sprite(g.renderer, &g.chars[1], ColorsEnum.WHITE)
    if char_texture == nil{
        SDL.Log("Error creating texture from sprite: %s", SDL.GetError())
        return false
    }

    smiley_char := Entity {
        id = "main",
        texture = char_texture,
        position = Position {
            x = SCREEN_WIDTH/2,
            y = SCREEN_HEIGHT/2
        },
        size = Size {
            w = g.chars[1].width * CHAR_SCALE,
            h = g.chars[1].height * CHAR_SCALE
        },
        is_active = true
    }

    append(&entity_manager.entities, smiley_char)

    return true
}

game_cleanup :: proc(g: ^Game) {
    if g != nil {
        if g.renderer != nil do SDL.DestroyRenderer(g.renderer)
        if g.window != nil do SDL.DestroyWindow(g.window)
        if g.chars != nil do delete(g.chars)
    }
    SDL.Quit()
}

game_run :: proc(g: ^Game){
    for{
        for SDL.PollEvent(&g.event){
            #partial switch g.event.type {
                case .QUIT:
                    return
                case .KEYDOWN:
                    #partial switch g.event.key.keysym.scancode {
                    case .UP:
                        move_entity("main", DirectionEnum.UP)
                        break
                    case .RIGHT:
                        move_entity("main", DirectionEnum.RIGHT)
                        break
                    case .DOWN:
                        move_entity("main", DirectionEnum.DOWN)
                        break
                    case .LEFT:
                        move_entity("main", DirectionEnum.LEFT)
                        break
                    case .ESCAPE:
                        return
                    }
            }
        }

        SDL.RenderClear(g.renderer)
        //Render objects
        //SDL.RenderCopy(g.renderer, char_texture, nil, &dst_rect)
        render_entities(&entity_manager)
        SDL.RenderPresent(g.renderer)
        SDL.Delay(16)
    }
}