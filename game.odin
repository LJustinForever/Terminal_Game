package main

import "core:fmt"
import SDL "vendor:sdl2"

CHAR_WIDTH :: 8
CHAR_HEIGHT :: 12

Game :: struct{
    window: ^SDL.Window,
    renderer: ^SDL.Renderer,
    event: SDL.Event,
    entity_manager: EntityManager
}

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
    g.entity_manager.entities = make([dynamic]Entity, 0, 30)

    bmp_texture := load_chars_from_BMP(g.renderer)
    if bmp_texture == nil  {
        SDL.Log("Error loading ascii: %s", SDL.GetError())
        return false
    }

    g.entity_manager.chars = extract_chars_from_texture(g.renderer, bmp_texture, CHAR_WIDTH, CHAR_HEIGHT)
    SDL.DestroyTexture(bmp_texture)
    if g.entity_manager.chars == nil{
        SDL.Log("Error extracting chars from texture: %s", SDL.GetError())
        return false
    }

    if !create_entity(g.renderer, &g.entity_manager, "main", 1, ColorsEnum.WHITE, Position{x=SCREEN_WIDTH/2, y=SCREEN_HEIGHT/2}){
        SDL.Log("Error unable to create entity: %s", SDL.GetError())
        return false
    }

    return true
}

game_cleanup :: proc(g: ^Game) {
    if g != nil {
        if g.renderer != nil do SDL.DestroyRenderer(g.renderer)
        if g.window != nil do SDL.DestroyWindow(g.window)
        if &g.entity_manager != nil {
            delete(g.entity_manager.chars)
            for &entity in g.entity_manager.entities{
                if entity.texture != nil{
                    SDL.DestroyTexture(entity.texture)
                }
            }
            delete(g.entity_manager.entities)
        }
    }
    SDL.Quit()
}

game_run :: proc(g: ^Game){
    for{
        SDL.RenderClear(g.renderer)
        //Render objects
        //SDL.RenderCopy(g.renderer, char_texture, nil, &dst_rect)
        render_entities(g.renderer, g.entity_manager)
        SDL.RenderPresent(g.renderer)
        SDL.Delay(16)

        for SDL.PollEvent(&g.event){
            #partial switch g.event.type {
                case .QUIT:
                    return
                case .KEYDOWN:
                    #partial switch g.event.key.keysym.scancode {
                    case .UP:
                        move_entity(&g.entity_manager, "main", DirectionEnum.UP)
                        break
                    case .RIGHT:
                        move_entity(&g.entity_manager, "main", DirectionEnum.RIGHT)
                        break
                    case .DOWN:
                        move_entity(&g.entity_manager, "main", DirectionEnum.DOWN)
                        break
                    case .LEFT:
                        move_entity(&g.entity_manager, "main", DirectionEnum.LEFT)
                        break
                    case .ESCAPE:
                        return
                    }
            }
        }
    }
}