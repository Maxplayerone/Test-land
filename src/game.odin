package game

import "core:fmt"
import rl "vendor:raylib"

_ :: fmt

Width :: 1280
Height :: 720

CellSize :: 16

GridWidth :: Width / CellSize
GridHeight :: Height / CellSize

GridSize :: GridWidth * GridHeight

Game_Memory :: struct {
	pos:    rl.Vector2,
	camera: rl.Camera2D,
}

g_mem: ^Game_Memory

@(export)
game_init_window :: proc() {
	rl.SetConfigFlags({.WINDOW_RESIZABLE, .VSYNC_HINT})
	rl.InitWindow(Width, Height, "Odin + Raylib + Hot Reload template!")
	rl.SetWindowPosition(200, 200)
	rl.SetTargetFPS(500)
}

@(export)
game_init :: proc() {
	g_mem = new(Game_Memory)

	g_mem^ = Game_Memory {
		pos = {CellSize * 20, CellSize * 20},
		camera = rl.Camera2D{zoom = 1.0, target = {0.0, 0.0}, offset = {Width / 2, Height / 2}},
	}

	game_hot_reloaded(g_mem)
}

abs :: proc(v: f32) -> f32 {
	if v > 0.0 {
		return v
	} else {
		return v * -1
	}
}

clamp_position :: proc(pos: ^rl.Vector2, value: f32) {
	remx := f32(int(pos.x) % int(value))
	if remx > 0.0 && remx >= value / 2 {
		pos.x += value - remx
	} else if remx > 0.0 && remx < value / 2 {
		pos.x -= remx
	} else if remx < 0.0 && abs(remx) >= value / 2 {
		pos.x -= value - abs(remx)
	} else if remx < 0.0 && abs(remx) < value / 2 {
		pos.x -= abs(remx)
	}
	remy := f32(int(pos.y) % int(value))
	if remy > 0.0 && remy >= value / 2 {
		pos.y += value - remy
	} else if remy > 0.0 && remy < value / 2 {
		pos.y -= remy
	} else if remy < 0.0 && abs(remy) >= value / 2 {
		pos.y -= value - abs(remy)
	} else if remy < 0.0 && abs(remy) < value / 2 {
		pos.x -= abs(remy)
	}
	pos.x = f32(int(pos.x))
	pos.y = f32(int(pos.y))
}

@(export)
game_update :: proc() -> bool {
	dt := rl.GetFrameTime()
	speed: f32 = 700
	input: rl.Vector2

	if rl.IsKeyDown(.W) {
		input.y -= speed * dt
	}
	if rl.IsKeyDown(.S) {
		input.y += speed * dt
	}
	if rl.IsKeyDown(.A) {
		input.x -= speed * dt
	}
	if rl.IsKeyDown(.D) {
		input.x += speed * dt
	}
	clamp_position(&input, CellSize)
	g_mem.pos += input

	if rl.IsKeyDown(.I) {
		g_mem.camera.target.y -= speed * dt
	}
	if rl.IsKeyDown(.K) {
		g_mem.camera.target.y += speed * dt
	}
	if rl.IsKeyDown(.J) {
		g_mem.camera.target.x -= speed * dt
	}
	if rl.IsKeyDown(.L) {
		g_mem.camera.target.x += speed * dt
	}

	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)

	rl.DrawRectangleRec({g_mem.pos.x, g_mem.pos.y, CellSize, CellSize}, rl.ORANGE)
	//rl.DrawRectangleRec({20.0, 100.0, 40.0, 40.0}, rl.RED)
	//rl.DrawRectangleRec({20.0, 0.0, 40.0, 40.0}, rl.BLUE)


	//rl.BeginMode2D(ui_camera())
	//rl.DrawRectangleRec({32.0, 32.0, 64.0, 64.0}, rl.WHITE)
	//rl.EndMode2D()

	line_color := rl.Color{255, 255, 255, 125}
	for i in 0 ..< GridWidth {
		rl.DrawLineEx({CellSize * f32(i), 0.0}, {CellSize * f32(i), Height}, 1.0, line_color)
	}
	for i in 0 ..< GridHeight {
		rl.DrawLineEx({0.0, CellSize * f32(i)}, {Width, CellSize * f32(i)}, 1.0, line_color)
	}

	rl.EndDrawing()

	return !rl.WindowShouldClose()
}

@(export)
game_shutdown :: proc() {
	free(g_mem)
}

@(export)
game_shutdown_window :: proc() {
	rl.CloseWindow()
}

@(export)
game_memory :: proc() -> rawptr {
	return g_mem
}

@(export)
game_memory_size :: proc() -> int {
	return size_of(Game_Memory)
}

@(export)
game_hot_reloaded :: proc(mem: rawptr) {
	g_mem = (^Game_Memory)(mem)
}

@(export)
game_force_reload :: proc() -> bool {
	return rl.IsKeyPressed(.Z)
}

@(export)
game_force_restart :: proc() -> bool {
	return rl.IsKeyPressed(.Q)
}
