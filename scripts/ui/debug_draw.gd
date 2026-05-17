extends Node2D

var show_collisions: bool = false
var player_hitbox: Rect2 = Rect2()
var collision_rects: Array = []   # массив [x, y, w, h] в тайлах
var tile_size: int = 48
var player_attack_range: float = 0.0
var player_position: Vector2 = Vector2.ZERO

var enemy_ranges: Array = []   # [{position: Vector2, range: float}, ...]

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
		
	# Радиус атаки игрока (жёлтый круг)
	if player_attack_range > 0:
		draw_circle(player_position, player_attack_range, Color(1, 1, 0, 0.2))  # заливка
		draw_arc(player_position, player_attack_range, 0, TAU, 32, Color.YELLOW, 1.0)  # контур
	
	# Радиусы атаки врагов (красные круги)
	for enemy in enemy_ranges:
		draw_circle(enemy.position, enemy.range, Color(1, 0, 0, 0.2))
		draw_arc(enemy.position, enemy.range, 0, TAU, 32, Color.RED, 1.0)
