extends CharacterBody2D

@export var speed: float = 180.0
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var direction: Vector2 = Vector2.ZERO
var map_collisions: Array = []
var map_width: int = 0
var map_height: int = 0
var tile_size: int = 64

func _ready():
	# Настраиваем анимации
	var frames = SpriteFrames.new()
	
	# Ходьба (pers.png)
	var walk_sheet = load("res://assets/sprites/main_person/pers.png")
	if walk_sheet:
		var w = walk_sheet.get_width() / 3   # 3 столбца
		var h = walk_sheet.get_height() / 4  # 4 строки
		# Анимации в порядке: down, left, right, up (как в оригинале)
		var anim_names = ["walk_down", "walk_left", "walk_right", "walk_up"]
		for row in range(4):
			var anim_name = anim_names[row]
			frames.add_animation(anim_name)
			for col in range(3):
				var rect = Rect2(col * w, row * h, w, h)
				var tex = AtlasTexture.new()
				tex.atlas = walk_sheet
				tex.region = rect
				frames.add_frame(anim_name, tex)
	
	# Стояние (idle.png)
	var idle_sheet = load("res://assets/sprites/main_person/idle.png")
	if idle_sheet:
		var iw = idle_sheet.get_width() / 2
		var ih = idle_sheet.get_height()      # 1 строка
		frames.add_animation("idle")
		for col in range(2):
			var rect = Rect2(col * iw, 0, iw, ih)
			var tex = AtlasTexture.new()
			tex.atlas = idle_sheet
			tex.region = rect
			frames.add_frame("idle", tex)
	else:
		# Если idle нет, копируем первый кадр walk_down как заглушку
		if frames.has_animation("walk_down"):
			var first_frame = frames.get_frame("walk_down", 0)
			frames.add_animation("idle")
			frames.add_frame("idle", first_frame)
	
	# Настройка скорости анимации (ANIMATION_SPEED 8 -> 60/8 = 7.5 fps)
	var anim_speed = 60.0 / 8.0   # 7.5 кадров в секунду
	for anim_name in frames.get_animation_names():
		frames.set_animation_speed(anim_name, anim_speed)
	
	anim.sprite_frames = frames
	anim.play("idle")

func set_map_info(width: int, height: int, collisions: Array, tsize: int):
	map_width = width
	map_height = height
	map_collisions = collisions
	tile_size = tsize

func _physics_process(delta):
	handle_input()
	update_animation()
	
	var move = direction * speed * delta
	var test_x = position + Vector2(move.x, 0)
	var test_y = position + Vector2(0, move.y)
	
	if not would_collide(test_x):
		position.x = test_x.x
	if not would_collide(test_y):
		position.y = test_y.y
	
	var bounds = get_map_bounds()
	position = Vector2(
		clamp(position.x, bounds.position.x, bounds.end.x),
		clamp(position.y, bounds.position.y, bounds.end.y)
	)

func handle_input():
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction.length() > 0:
		direction = direction.normalized()

func update_animation():
	if direction == Vector2.ZERO:
		anim.play("idle")
	elif abs(direction.y) > abs(direction.x):
		if direction.y > 0:
			anim.play("walk_down")
		else:
			anim.play("walk_up")
	else:
		if direction.x < 0:
			anim.play("walk_left")
		else:
			anim.play("walk_right")

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
