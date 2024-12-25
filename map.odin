package main

import "core:os"
import "core:strings"
import "core:fmt"
import "core:strconv"
import "core:unicode/utf8"
import SDL "vendor:sdl2"

TILE_FLOOR_CHAR_ID :: 249
TILE_WALL_CHAR_ID :: 219

TileMapTypeEnum :: enum{
    EMPTY = 0,
    WALL = 1,
    FLOOR = 2,
    PLAYER = 3
}

Tile :: struct {
    position: Position,
    size: Size,
    texture: ^SDL.Texture,
    type: TileMapTypeEnum
}

TileMap :: distinct [dynamic]Tile

create_tilemap :: proc(renderer: ^SDL.Renderer, source_tilemap: [dynamic][dynamic]int, chars: []CharacterSprite, color_enum: ColorsEnum) -> TileMap {
    tilemap := make(TileMap)
    for y := 0; y < len(source_tilemap); y += 1 {
        for x := 0; x < len(source_tilemap[y]); x += 1{
            tile : Tile
            ok : bool
            switch transmute(TileMapTypeEnum)source_tilemap[y][x] {
                case .FLOOR:
                    tile, ok = create_tile(renderer, x + SCREEN_WIDTH / 2, y +  SCREEN_HEIGHT / 2, TileMapTypeEnum.FLOOR, &chars[TILE_FLOOR_CHAR_ID], color_enum).?
                    break
                case .WALL:
                    tile, ok = create_tile(renderer, x + SCREEN_WIDTH / 2, y +  SCREEN_HEIGHT / 2, TileMapTypeEnum.WALL, &chars[TILE_WALL_CHAR_ID], color_enum).?
                    break
                case .EMPTY: //TODO: ?
                    fallthrough
                case .PLAYER: //TODO: ?
                    fallthrough
                case:
                    ok = true
                    break
            }
            if !ok {
                return nil
            }
            append(&tilemap, tile)
        }
    }
    return tilemap
}

create_tile :: proc(renderer: ^SDL.Renderer,x: int, y: int, type: TileMapTypeEnum, sprite: ^CharacterSprite, color_enum: ColorsEnum) -> Maybe(Tile) {
    tile_texture := create_texture_from_sprite(renderer, sprite, color_enum)
    if tile_texture == nil {
        return nil
    }
    tile := Tile {
        position = Position{
            x = x,
            y = y
        },
        size = Size{
            w = sprite.width,
            h = sprite.height
        },
        texture = tile_texture,
        type = type
    }

    return tile
}

render_tilemap :: proc(renderer: ^SDL.Renderer, tile_map: TileMap){
    for &tile in tile_map{
        rect := SDL.Rect{
            x = i32(tile.position.x),
            y = i32(tile.position.y),
            w = i32(tile.size.w),
            h = i32(tile.size.h),
        }
        //TODO: Handle errors
        SDL.RenderCopy(renderer, tile.texture, nil, &rect)
        fmt.println("Drawing at ", tile.position.x, " ", tile.position.y)
    }
}

get_source_tilemap_from_file :: proc(path: string) -> Maybe([dynamic][dynamic]int) {
    data, ok := os.read_entire_file(path, context.allocator)
    if !ok {
        return nil
    }
    defer delete(data, context.allocator)

    tilemap := make([dynamic][dynamic]int)

    it := string(data)
    for line in strings.split_lines_iterator(&it){
        new_row := make([dynamic]int)
        for value in line {
            rn := []rune{value}
            append(&new_row, strconv.atoi(utf8.runes_to_string(rn)))
        }
        append(&tilemap, new_row)
    }

    return tilemap
}