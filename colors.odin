package main

ColorsEnum :: enum{
    WHITE = 0,
    RED = 1,
    YELLOW = 2,
    GRAY = 3
}

get_color :: proc(color_enum: ColorsEnum) -> [3]u8 {
    switch color_enum{
        case .WHITE:
            return [3]u8{255,255,255}
        case .RED:
            return [3]u8{255,0,0}
        case .YELLOW:
            return [3]u8{255,255,0}
        case .GRAY:
            return [3]u8{105,105,105}
    }
    return [3]u8{0,0,0}
}