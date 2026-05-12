extends Node2D

var show_collisions: bool = false
var player_hitbox: Rect2 = Rect2()
var collision_rects: Array = []   # массив [x, y, w, h] в тайлах
var tile_size: int = 48

func _draw():
	if not show_collisions:
		return
	
	# Хитбокс персонажа (зелёный контур)
	if player_hitbox.size != Vector2.ZERO:
		draw_rect(player_hitbox, Color.GREEN, false, 1.0)
	
	# Коллизии карты (красные полупрозрачные прямоугольники с контуром)
	for col in collision_rects:
		var rect = Rect2(col[0] * tile_size, col[1] * tile_size, 
						col[2] * tile_size, col[3] * tile_size)
		draw_rect(rect, Color(1, 0, 0, 0.4))    # заливка
		draw_rect(rect, Color.RED, false, 1.0)  # контур
