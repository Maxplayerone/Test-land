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
    if rl.IsKeyDown(.W){
        move.y = -p.speed.x * dt
    }
    if rl.IsKeyDown(.S){
        move.y = p.speed.x * dt
    }
        /*
    if rl.IsKeyPressed(.SPACE){
        p.speed.y = p.start_vert_speed
    }
    move.y = -(0.5 * p.g * dt * dt + p.speed.y * dt)
    */
    /*
    if rl.IsMouseButtonDown(.LEFT){
        move = rl.GetMouseDelta()
    }
        */

    for block, i in blocks{
        //bottom, top, right, left 
        collision: [4]bool
        for dir in 0..<4{
            if dir == 0 && move.y < 0.0 do continue
            if dir == 1 && move.y > 0.0 do continue
            if dir == 2 && move.x < 0.0 do continue
            if dir == 3 && move.x > 0.0 do continue

            if rl.CheckCollisionPointRec(p.pos + move + p.collission_points[dir*2], block) && rl.CheckCollisionPointRec(p.pos + move + p.collission_points[2*dir+1], block){
                collision[dir] = true
            }
        }

        /*
        if collision[0]{
            move.y = block.y + block.height - (p.pos.y + move.y)
        }
        if collision[1]{
            move.y = -(p.pos.y + move.y + p.size - block.y)
        }
        */
        if collision[2]{
            fmt.println("colliding on the right")
            //move.x = block.x - p.size - p.pos.x
        }
        if collision[3]{
            fmt.println("colliding on the left")
            move.x = block.x - p.size - p.pos.x - 1
        }
            /*
        if rl.CheckCollisionRecs(get_rect(p.pos + move, p.size), block){
            if move.y < 0.0{
                move.y = block.y + block.height - p.pos.y
            }
            if move.y > 0.0{
                move.y = block.y - p.size - p.pos.y
            }

            if move.x < 0.0{
                move.x = block.x + block.width - p.pos.x
            }
            if move.x > 0.0{
                move.x = block.x - p.size - p.pos.x
            }
        }
            */
    }
    p.pos += move

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