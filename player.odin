package main

import rl "vendor:raylib"

import "core:fmt"
import "core:math"

Player :: struct{
    color: rl.Color,
    size: f32,

    pos: rl.Vector2,
    speed: rl.Vector2,
    start_vert_speed: f32,

    g: f32,
    gravity_landing: f32,
    gravity_jumping: f32,

    deg: f32,

    jump_time_before_check: int,
    collission_points: [8]rl.Vector2,
}

player_rect :: proc(p: Player) -> rl.Rectangle{
    return rl.Rectangle{p.pos.x, p.pos.y, p.size, p.size}
}

player_update :: proc(p: ^Player, blocks: [dynamic]rl.Rectangle, block_colours: ^[dynamic]rl.Color){
    dt := rl.GetFrameTime()

    for &color in block_colours{
        color = rl.WHITE
    }

    move: rl.Vector2
    if rl.IsKeyDown(.D){
        move.x = p.speed.x * dt
    }
    if rl.IsKeyDown(.A){
        move.x = -p.speed.x * dt
    }
    if rl.IsKeyPressed(.SPACE){
        p.speed.y = p.start_vert_speed
    }
    move.y = -(0.5 * p.g * dt * dt + p.speed.y * dt)

    for block in blocks{
        if rl.CheckCollisionRecs(get_rect({p.pos.x + move.x, p.pos.y}, p.size), block){
            if move.x > 0.0{
                move.x = block.x - p.size - p.pos.x
            }
            if move.x < 0.0{
                move.x = block.x + block.width - p.pos.x
            }
        }
        if rl.CheckCollisionRecs(get_rect({p.pos.x, p.pos.y + move.y}, p.size), block){
            if move.y > 0.0{
                move.y = block.y - p.size - p.pos.y
            }
            if move.y < 0.0{
                move.y = block.y + block.height - p.pos.y
            }

            p.speed.y = 0
        }
    }
    p.pos += move
    p.speed.y += p.g * dt

    //getting the angle between player and mouse
    mouse_pos := rl.GetMousePosition()
    dx := mouse_pos.x - p.pos.x
    dy := mouse_pos.y - p.pos.y
    p.deg = math.atan2(dy, dx) * (180.0 / 3.14) - 90.0

}

player_render :: proc(p: Player){
    rl.DrawRectangleRec(player_rect(p), p.color)
    rl.DrawRectanglePro(rl.Rectangle{p.pos.x + p.size / 2, p.pos.y + p.size / 2, 5.0, 40.0}, {0.0, 0.0}, p.deg, rl.RED)
}