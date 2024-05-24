package main

import rl "vendor:raylib"

import "core:fmt"
import "core:math"
import "core:strings"
import "core:sys/windows"
import "core:mem"
import "core:unicode"

Width :: 960
Height :: 720

//1. loop over each character in text
//2.1. if there is no whitespace add it to temp_string
//2.2. if there is whitespace
//2.2.1. if adding the string to the current row would not result in overflowing the width add it to cur_row
//2.2.2. if adding the string to the current row would result in overflow add the cur_row to texts_buf and reset it

/*
divide_text :: proc(text: string, character_len: int, rect_width: int) -> []string{
    texts_buf := make([dynamic]string, 0, 5, context.temp_allocator)
    temp_string: string
    cur_row: string
    line_len := 0
    for c in text{
        if unicode.is_space(c){
            append(&texts_buf, temp_string)
            temp_string = ""
        }
        else{
            b := strings.builder_make(context.temp_allocator)
            strings.write_string(&b, temp_string)
            strings.write_rune(&b, c)
            temp_string = strings.to_string(b)
        }
    }
    append(&texts_buf, temp_string)
    return texts_buf[:] 
}
*/

/*
divide_text :: proc(text: string, character_len: int, rect_width: int) -> []string{
    texts_buf := make([dynamic]string, 0, 5)
    line_len, last: int
    for _, p in text {
        if (line_len + character_len) < rect_width {
            line_len += character_len
        } else {
            append(&texts_buf, text[last:p])
            last = p
            line_len = 0
        }
    }
    append(&texts_buf, text[last:])
    return texts_buf[:]
}
*/



main :: proc(){
    rl.InitWindow(Width, Height, "test")
    rl.SetTargetFPS(60)

    tracking_allocator: mem.Tracking_Allocator
    mem.tracking_allocator_init(&tracking_allocator, context.allocator)
    context.allocator = mem.tracking_allocator(&tracking_allocator)

    windows.SetConsoleOutputCP(windows.CP_UTF8)

    text := "This is a random string of letters"
    character_len: f32 = 15.0 

    font := rl.LoadFontEx("roboto/Roboto-Black.ttf", 32, nil, 1024)
    width: f32 = 300.0
    texts_buf := divide_text(text, int(character_len), int(width))
    for t in texts_buf{
        fmt.println(t)
    }

    for !rl.WindowShouldClose(){
        rl.BeginDrawing()
        defer rl.EndDrawing()

        rl.DrawRectangleRec(rl.Rectangle{200.0, 100, width, 450.0}, rl.WHITE)
        for t, i in texts_buf{
            rl.DrawTextEx(font, strings.clone_to_cstring(t, context.temp_allocator), {200.0, 100.0 + (character_len * 2.0 * f32(i))}, character_len * 2.0, 2.0, rl.BLUE)
            //fmt.println(t)
        }

        rl.ClearBackground(rl.BLACK)
        //free_all(context.temp_allocator)
    }
    rl.CloseWindow()

    for key, value in tracking_allocator.allocation_map{
        fmt.printf("%v: Leaked %v bytes\n", value.location, value.size)
    }
}