package main

import "core:fmt"
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
    chars: []CharacterSprite //holds all characters from bmp
}

create_entity :: proc(renderer: ^SDL.Renderer, entity_manager: ^EntityManager, id: string, char_id: int,
    color: ColorsEnum, source_position: Position, source_is_active := true) -> bool{

    if get_entity(entity_manager, id) != nil{
        fmt.println("create_entity failed: Could not create entity id exists")
        return false
    }

    char_texture := create_texture_from_sprite(renderer, &entity_manager.chars[char_id], color)
    if char_texture == nil{
        return false
    }

    char := Entity {
        id = id,
        texture = char_texture,
        position = Position{
            x = source_position.x,
            y = source_position.y
        },
        size = Size {
            w = entity_manager.chars[char_id].width * CHAR_SCALE,
            h = entity_manager.chars[char_id].height * CHAR_SCALE
        },
        is_active = source_is_active
    }

    append(&entity_manager.entities, char)

    return true
}

render_entities :: proc(renderer: ^SDL.Renderer, entity_manager: EntityManager){
    for &entity in entity_manager.entities {
        if entity.is_active {
            render_entity(renderer, &entity)
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

get_entity :: proc(entity_manager: ^EntityManager, id: string) -> ^Entity {
    for &entity in entity_manager.entities {
        if entity.id == id {
            return &entity
        }
    }
    return nil
}

move_entity :: proc(entity_manager: ^EntityManager, id: string, direction: DirectionEnum){
    entity := get_entity(entity_manager,id)
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