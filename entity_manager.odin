package main

import SDL "vendor:sdl2"


DirectionEnum :: enum{
    LEFT,
    UP,
    RIGHT,
    DOWN
}

Size :: struct{
    w: int,
    h: int
}

Position :: struct{
    x: int,
    y: int
}

Entity :: struct{
    id: string,
    texture: ^SDL.Texture,
    position: Position,
    size: Size,
    is_active: bool
}

EntityManager :: struct{
    entities: [dynamic]Entity,
    renderer: ^SDL.Renderer
}

render_entities :: proc(entity_manager: ^EntityManager){
    for &entity in entity_manager.entities {
        if entity.is_active {
            render_entity(entity_manager.renderer, &entity)
        }
    }
}

render_entity :: proc(renderer: ^SDL.Renderer, entity: ^Entity){
    rect := SDL.Rect{
        x = i32(entity.position.x),
        y = i32(entity.position.y),
        w = i32(entity.size.w),
        h = i32(entity.size.h)
    }
   //TODO: Handle errors
    SDL.RenderCopy(renderer, entity.texture, nil, &rect)
}

get_entity :: proc(id: string) -> ^Entity {
    for &entity in entity_manager.entities {
        if entity.id == id {
            return &entity
        }
    }
    return nil
}

move_entity :: proc(id: string, direction: DirectionEnum){
    entity := get_entity(id)
    switch direction{
        case .LEFT:
            entity.position.x -= CHAR_WIDTH
            break
        case .RIGHT:
            entity.position.x += CHAR_WIDTH
            break
        case .UP:
            entity.position.y -= CHAR_HEIGHT
            break
        case .DOWN:
            entity.position.y += CHAR_HEIGHT
            break
    }
    return
}