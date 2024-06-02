package main

import "core:fmt"
import "core:strings"
import "core:unicode/utf8"
import "core:mem"
import "core:sys/windows"

import rl "vendor:raylib"

Width :: 960
Height :: 720

divide_by_space :: proc(text: string) -> []string{
    words_buf := make([dynamic]string, 0, 5)
    last: int
    for c, i in text{
        if c == ' '{
            append(&words_buf, text[last: i])
            last = i
        }
    }
    append(&words_buf, text[last:])
    return words_buf[:]
}

//returns rows of text that fit into rect's width
fit_text_on_rect :: proc(text: string, character_len: int, rect_width: int) -> []string{
    words := divide_by_space(text) 
    rows_buf := make([dynamic]string, 0, 5)

    row_len, last: int
    for word, i in words{
        if row_len + unicode_len(word) * character_len < rect_width{
            row_len += unicode_len(word) * character_len
            fmt.println(row_len, rect_width, i, "no add", word)
        }
        else{
            fmt.println(row_len + unicode_len(word) * character_len, rect_width, i, "add", word)
            append(&rows_buf, strings.concatenate(words[last:i], context.temp_allocator))
            last = i
            row_len = unicode_len(word) * character_len
        }
    }
    append(&rows_buf, strings.concatenate(words[last:], context.temp_allocator))

    delete(words)
    return rows_buf[:] 
}

unicode_len :: proc(text: string) -> int{
    len := len(text)
    for c in text{
        if c > 127{
            len -= 1
        }
    }
    return len
}

main :: proc(){
    rl.InitWindow(Width, Height, "test")
    rl.SetTargetFPS(60)

    tracking_allocator: mem.Tracking_Allocator
    mem.tracking_allocator_init(&tracking_allocator, context.allocator)
    context.allocator = mem.tracking_allocator(&tracking_allocator)

    windows.SetConsoleOutputCP(windows.CP_UTF8)

    //text := "This is a random string of letters. I'm still testing if this works fully- if it does than it's great"
    text := "Zobaczmy czy zadziała to też z polskimi literami. Mam nadzieję że tak"
    character_len: f32 = 15.0 

    font := rl.LoadFontEx("roboto/Roboto-Black.ttf", 32, nil, 1024)
    width: f32 = 300.0
    //texts_buf := divide_by_space(text)
    texts_buf := fit_text_on_rect(text, int(character_len), int(width))

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
    delete(texts_buf)
    fmt.println("closed the window")
    rl.CloseWindow()

    for key, value in tracking_allocator.allocation_map{
        fmt.printf("%v: Leaked %v bytes\n", value.location, value.size)
    }
}
