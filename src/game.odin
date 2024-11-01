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
	pos:          rl.Vector2,
	camera:       rl.Camera2D,
	start_target: rl.Vector2,
	bg:           rl.Texture2D,
	x, y:         int,
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
		camera = rl.Camera2D {
			zoom = 1.0,
			//target = {Width / 2, Height / 2},
			//offset = {Width / 2, Height / 2},
		},
		start_target = {Width / 2, Height / 2},
		bg = rl.LoadTexture("res/bg.png"),
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

get_camera_offset :: proc(camera: rl.Camera2D, start_target: rl.Vector2) -> rl.Vector2 {
	return camera.target - start_target
}

camera_moved_cells_offset :: proc(
	camera: rl.Camera2D,
	cell_size: f32,
	start_target := rl.Vector2{0.0, 0.0},
) -> (
	int,
	int,
) {
	x := int(camera.target.x / cell_size)
	y := int(camera.target.y / cell_size)
	return x, y
}

@(export)
game_update :: proc() -> bool {
	dt := rl.GetFrameTime()
	speed: f32 = 700
	//input: rl.Vector2

	/*
	if rl.IsKeyDown(.W) {
		g_mem.camera.offset.y -= speed * dt
	}
	if rl.IsKeyDown(.S) {
		g_mem.camera.offset.y += speed * dt
	}
	if rl.IsKeyDown(.A) {
		g_mem.camera.offset.x -= speed * dt
	}
	if rl.IsKeyDown(.D) {
		g_mem.camera.offset.x += speed * dt
	}
	*/
	//clamp_position(&input, CellSize)
	//g_mem.pos += input

	if rl.IsKeyDown(.W) {
		g_mem.camera.target.y -= speed * dt
	}
	if rl.IsKeyDown(.S) {
		g_mem.camera.target.y += speed * dt
	}
	if rl.IsKeyDown(.A) {
		g_mem.camera.target.x -= speed * dt
	}
	if rl.IsKeyDown(.D) {
		g_mem.camera.target.x += speed * dt
	}

	/*
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)

	rl.DrawRectangleRec({g_mem.pos.x, g_mem.pos.y, CellSize * 5, CellSize * 5}, rl.ORANGE)

	rl.BeginMode2D(g_mem.camera)

	line_color := rl.Color{255, 255, 255, 125}
	//start_offset := get_camera_offset(g_mem.camera, g_mem.start_target)
	start_offset: [2]f32 = {0.0, 0.0}
	for i in 0 ..< GridWidth {
		rl.DrawLineEx(
			{start_offset.x + CellSize * f32(i), start_offset.y},
			{start_offset.x + CellSize * f32(i), start_offset.y + Height},
			1.0,
			line_color,
		)
	}
	for i in 0 ..< GridHeight {
		rl.DrawLineEx(
			{start_offset.x, start_offset.y + CellSize * f32(i)},
			{start_offset.x + Width, start_offset.y + CellSize * f32(i)},
			1.0,
			line_color,
		)
	}

	rl.EndMode2D()

	rl.EndDrawing()
	*/

	//x, y := camera_moved_cells_offset(g_mem.camera, CellSize)
	if rl.IsKeyPressed(.RIGHT) {
		g_mem.x += CellSize
	}
	if rl.IsKeyPressed(.LEFT) {
		g_mem.x -= CellSize
	}

	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)

	rl.BeginMode2D(g_mem.camera)

	//start_offset := get_camera_offset(g_mem.camera, {0.0, 0.0})
	line_color := rl.Color{255, 255, 255, 125}
	x, y := camera_moved_cells_offset(g_mem.camera, CellSize)
	for i in x ..< GridWidth + x {
		rl.DrawLineEx(
			{CellSize * f32(i), f32(y) * CellSize},
			{CellSize * f32(i), f32(y) * CellSize + Height},
			1.0,
			line_color,
		)
	}
	//horizontal lines
	for i in y ..< GridHeight + y {
		rl.DrawLineEx(
			{f32(x) * CellSize, CellSize * f32(i)},
			{f32(x) * CellSize + Width, CellSize * f32(i)},
			1.0,
			line_color,
		)
	}
	rl.DrawRectangleRec({Width / 2 - 50, Height / 2 - 50, 100, 100}, rl.WHITE)

	rl.DrawRectangleRec({Width, Height, 40, 40}, rl.ORANGE)

	rl.EndMode2D()

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
