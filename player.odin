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

player_update :: proc(p: ^Player, blocks: [dynamic]rl.Rectangle){
    dt := rl.GetFrameTime()
    //horizontal movement
    /*
    if rl.IsKeyDown(.D){
        pos_x_offset = p.speed.x * dt

        if !wall_collission(blocks, {p.pos.x + pos_x_offset + p.size, p.pos.y}){
            p.pos.x += pos_x_offset 
        }
    }
    if rl.IsKeyDown(.A){
        pos_x_offset = -p.speed.x * dt

        if !wall_collission(blocks, {p.pos.x + pos_x_offset + p.size, p.pos.y}){
            p.pos.x += pos_x_offset 
        }
    }

    new_y_pos := -(0.5 * p.g * dt * dt + p.speed.y * dt)
    if ceiling_collission(blocks, {p.pos.x, new_y_pos, p.size, 0.0}){
        p.g = p.gravity_landing
        p.speed.y = 0.0
        p.pos.y = blocks[2].y + blocks[2].height
    }

    //testing for collission with the floor
    if is_colliding, floor_y := floor_collission(blocks, {p.pos.x, p.pos.y + p.size + 1.0}, p.size); is_colliding && p.jump_time_before_check <= 0{
        p.pos.y = floor_y - p.size
        p.speed.y = 0 //we are treating every surface like it's elevated

    }
    else{
        p.pos.y -= 0.5 * p.g * dt * dt + p.speed.y * dt
        p.speed.y += p.g * dt

        if p.speed.y > 0{
            p.g = p.gravity_jumping
        }
        else{
            p.g = p.gravity_landing
        }

    }

    if rl.IsKeyPressed(.SPACE){
        p.speed.y = p.start_vert_speed
        p.g = p.gravity_jumping

        p.pos.y -= 0.5 * p.g * dt * dt + p.speed.y * dt
        p.speed.y += p.g * dt

        p.jump_time_before_check = 5
    }

    p.jump_time_before_check -= 1
    */

    updated_movement_x: bool
    updated_movement_y: bool
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

    iterations := 1
    contactX := true
    contact_bottom := true
    contact_top := true
    for i := 0; i < iterations && (contactX || contact_bottom || contact_top); i += 1{
        contactX = false
        contact_bottom = false
        contact_top = false

        projected_move: rl.Vector2

        original_move := move
        for j := 0; j < len(blocks) && !contactX && !contact_bottom && !contact_top; j += 1{
            //0 = top, 1 = bottom, 2 = left, 3 = right
            for dir in 0..<4{
                if dir == 0 && move.y > 0.0 do continue
                if dir == 1 && move.y < 0.0 do continue
                if dir == 2 && move.x > 0.0 do continue
                if dir == 3 && move.x < 0.0 do continue

                projected_move.x = dir >= 2 ? move.x : 0
                projected_move.y = dir < 2 ? move.y : 0


                for rl.CheckCollisionPointRec(p.collission_points[dir*2] + p.pos + projected_move, blocks[j]) || rl.CheckCollisionPointRec(p.collission_points[dir * 2 + 1] + p.pos + projected_move, blocks[j]){
                    if dir == 0 do projected_move.y += 1
                    if dir == 1 do projected_move.y-= 1
                    if dir == 2 do projected_move.x += 1
                    if dir == 3 do projected_move.x -= 1

                    if dir >= 2 && dir <= 3 do move.x = projected_move.x
                    if dir >= 0 && dir <= 1 do move.y = projected_move.y
                }
            }

            if move.y > original_move.y && original_move.y < 0{
                contact_top = true
            }
            if move.y < original_move.y && original_move.y > 0{
                contact_bottom = true
            }
            if abs(move.x - original_move.x) > 0.01{
                contactX = true
            }

            if contactX && contact_top && p.speed.y < 0.0{
                p.speed.y = 0
                move.y = 0
            }
        }

        if contact_bottom || contact_top{
            p.pos.y += move.y
            p.speed.y += p.g * dt
            updated_movement_y = true
        }
        if contactX{
            p.pos.x += move.x
            updated_movement_x = true
        }
    }

    if !updated_movement_x{
        p.pos.x += move.x
    }
    if !updated_movement_y{
        p.pos.y += move.y
        p.speed.y += p.g * dt
    }

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