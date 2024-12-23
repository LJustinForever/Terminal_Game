package main

import SDL "vendor:sdl2"

CHAR_SCALE :: 2

CharacterSprite :: struct  {
    pixels: [dynamic]u32,
    width: int,
    height: int
}

//Returns ^SDL.Texture
load_chars_from_BMP :: proc(renderer: ^SDL.Renderer) -> (^SDL.Texture) {
    ascii_surface := SDL.LoadBMP("ascii.bmp")
    if ascii_surface == nil {
        return nil
    }

    ascii_texture := SDL.CreateTextureFromSurface(renderer, ascii_surface)
    if ascii_texture == nil {
        return nil
    }

    SDL.FreeSurface(ascii_surface)

    return ascii_texture
}

extract_chars_from_texture :: proc(renderer: ^SDL.Renderer, source_texture: ^SDL.Texture,
    char_width, char_height: i32) -> (chars: []CharacterSprite) {
    texture_width, texture_height: i32

    if SDL.QueryTexture(source_texture, nil, nil, &texture_width, &texture_height) < 0 {
        return nil
    }

    target_texture := SDL.CreateTexture(renderer,
        SDL.PixelFormatEnum.RGBA32,
        SDL.TextureAccess.TARGET,
        texture_width,
        texture_height)
    if target_texture == nil {
        return nil
    }
    defer SDL.DestroyTexture(target_texture)

    SDL.SetRenderTarget(renderer, target_texture)
    SDL.RenderCopy(renderer, source_texture, nil, nil)

    surface := SDL.CreateRGBSurfaceWithFormat(0,
        texture_width,
        texture_height,
        32,
        u32(SDL.PixelFormatEnum.RGBA32))
    if surface == nil {
        return nil
    }
    defer SDL.FreeSurface(surface)

    if SDL.RenderReadPixels(renderer, nil, u32(SDL.PixelFormatEnum.RGBA32), surface.pixels, surface.pitch) < 0 {
        return nil
    }

    SDL.SetRenderTarget(renderer, nil)

    chars_per_row := texture_width / char_width
    chars_per_column := texture_height / char_height

    total_chars := chars_per_row * chars_per_column
    chars = make([]CharacterSprite, total_chars)

    pixels := ([^]u32)(surface.pixels)
    char_index := 0

    for y := 0; y < int(chars_per_column); y += 1 {
        for x := 0; x < int(chars_per_row); x += 1 {
            sprite_pixels := make([dynamic]u32, char_width * char_height)

            for py := 0; py < int(char_height); py += 1 {
                for px := 0; px < int(char_width); px += 1 {
                    surface_x := x * int(char_width) + px
                    surface_y := y * int(char_height) + py
                    pixel_index := surface_y * int(texture_width) + surface_x
                    sprite_pixels[py * int(char_width) + px] = pixels[pixel_index]
                }
            }

            chars[char_index] = CharacterSprite{
                pixels = sprite_pixels,
                width = int(char_width),
                height = int(char_height),
            }
            char_index += 1
        }
    }

    return chars
}

create_texture_from_sprite :: proc(renderer: ^SDL.Renderer, sprite: ^CharacterSprite, color_enum: ColorsEnum)  -> ^SDL.Texture{
    //Change color
    sprite_pixels := make([dynamic]u32, sprite.width * sprite.height)
    for py := 0; py < int(sprite.height); py += 1 {
        for px := 0; px < int(sprite.width); px += 1 {
            surface_x := px
            surface_y := py
            pixel_index := surface_y * int(sprite.width) + surface_x

            pixel := sprite.pixels[pixel_index]
            r := u8(pixel)
            g := u8(pixel >> 8)
            b := u8(pixel >> 16)
            a := u8(pixel >> 24)

            if r != 0 || g != 0 || b != 0 {
                color := get_color(color_enum)
                r = u8(color[0])
                g = u8(color[1])
                b = u8(color[2])

                // Recombine RGBA into a single 32-bit pixel
                sprite_pixels[py * int(sprite.width) + px] = (u32(r) << 24) | (u32(g) << 16) | (u32(b) << 8) | u32(a)
            }
        }
    }
    sprite.pixels = sprite_pixels

    texture := SDL.CreateTexture(renderer, .RGBA32, .STATIC, i32(sprite.width), i32(sprite.height))
    if texture == nil {
        return nil
    }
    if SDL.UpdateTexture(texture, nil, raw_data(sprite.pixels), i32(sprite.width * size_of(u32))) < 0{
        SDL.DestroyTexture(texture)
        return nil
    }

    SDL.SetTextureBlendMode(texture, .BLEND)

    return texture
}