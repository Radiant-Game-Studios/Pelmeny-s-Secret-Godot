extends CharacterBody2D

@export var speed: float = 180.0   # 3 * 60 (пикселей в секунду)

var direction: Vector2 = Vector2.ZERO
var map_collisions: Array = []
var map_width: int = 0
var map_height: int = 0
var tile_size: int = 64             # не export, задаётся картой

func set_map_info(width: int, height: int, collisions: Array, tsize: int):
	map_width = width
	map_height = height
	map_collisions = collisions
	tile_size = tsize

func _physics_process(delta):
	handle_input()
	var move = direction * speed * delta
	var test_x = position + Vector2(move.x, 0)
	var test_y = position + Vector2(0, move.y)

	if not would_collide(test_x):
		position.x = test_x.x
	if not would_collide(test_y):
		position.y = test_y.y

	# Ограничиваем картой
	var bounds = get_map_bounds()
	position = Vector2(
		clamp(position.x, bounds.position.x, bounds.end.x),
		clamp(position.y, bounds.position.y, bounds.end.y)
	)

func handle_input():
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction.length() > 0:
		direction = direction.normalized()

func would_collide(test_pos: Vector2) -> bool:
	var shape: RectangleShape2D = $CollisionShape2D.shape
	var col_pos = $CollisionShape2D.position
	var rect = Rect2(test_pos + col_pos, shape.size)

	for col in map_collisions:
		var cx = col[0] * tile_size
		var cy = col[1] * tile_size
		var cw = col[2] * tile_size
		var ch = col[3] * tile_size
		if rect.intersects(Rect2(cx, cy, cw, ch)):
			return true
	return false

func get_map_bounds() -> Rect2:
	var shape: RectangleShape2D = $CollisionShape2D.shape
	var col_offset = $CollisionShape2D.position
	var max_x = map_width * tile_size - col_offset.x - shape.size.x
	var max_y = map_height * tile_size - col_offset.y - shape.size.y
	return Rect2(-col_offset.x, -col_offset.y, max_x + col_offset.x, max_y + col_offset.y)
