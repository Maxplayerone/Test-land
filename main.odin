package main

import "core:fmt"
import "core:mem"

import rl "vendor:raylib"

Width :: 960
Height :: 720

main :: proc(){
    tracking_allocator: mem.Tracking_Allocator
    mem.tracking_allocator_init(&tracking_allocator, context.allocator)
    context.allocator = mem.tracking_allocator(&tracking_allocator)

    rl.InitWindow(Width, Height, "game")
    rl.SetWindowState({.WINDOW_RESIZABLE})
    rl.SetTargetFPS(60)

    player := Player{}
    player.size = 40.0
    //player.pos = rl.Vector2{Width / 2 - player.size / 2, Height / 2 - player.size / 2 + 100.0}
    player.pos = rl.Vector2{800.0, 200.0}
    player.color = rl.Color{125, 255, 207, 255}
    player.speed.x = 400.0

    jump_height:f32 = 200.0
    jump_dist: f32 = 150.0

    player.start_vert_speed = 2 * jump_height * player.speed.x / jump_dist
    player.g = - 2 * jump_height * (player.speed.x * player.speed.x) / (jump_dist * jump_dist)
    player.gravity_jumping = player.g
    player.gravity_landing = 2 * player.g
    player.collission_points = generate_collission_points(player.size)

    rect := get_rect(player.pos, player.size)

    blocks: [dynamic]rl.Rectangle
    append(&blocks, rl.Rectangle{0.0, Height - 100.0 + player.size, Width, 100.0})
    append(&blocks, rl.Rectangle{200.0, 400.0, 100.0, 300.0})
    append(&blocks, rl.Rectangle{700.0, 300.0, 150.0, 50.0})
    block_colours: [dynamic]rl.Color
    for _ in 0..<len(blocks){
        append(&block_colours, rl.WHITE)
    }
    //append(&blocks, rl.Rectangle{400.0, 100.0, 100.0, 200.0})

    for !rl.WindowShouldClose(){

        player_update(&player, blocks, &block_colours)
        //fmt.println(player.speed, player.g, player.pos)

        rl.BeginDrawing()
        rl.ClearBackground(rl.BLACK)

        if rl.IsKeyPressed(.ONE){
            player.pos.x = 100
        }
        if rl.IsKeyPressed(.TWO){
            player.pos.x = 900
        }

        for block, i in blocks{
            rl.DrawRectangleRec(block, block_colours[i])
        }

        player_render(player)

        rl.EndDrawing()
    }
    delete(blocks)
    delete(block_colours)

    rl.CloseWindow()

    for key, value in tracking_allocator.allocation_map{
        fmt.printf("%v: Leaked %v bytes\n", value.location, value.size)
    }
}