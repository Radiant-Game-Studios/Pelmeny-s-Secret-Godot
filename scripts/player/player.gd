extends CharacterBody2D

signal teleport_attempted(target_map: String)

@export var speed: float = 180.0
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hint_label: Label = $Label

var direction: Vector2 = Vector2.ZERO
var map_collisions: Array = []
var map_width: int = 0
var map_height: int = 0
var tile_size: int = 64
var teleport_points: Array = []
var step_timer: float = 0.0
var step_interval: float = 0.4  # интервал между шагами
var step_sfx: AudioStream = null
var step_player: AudioStreamPlayer = null
var is_attacking: bool = false
var attack_damage: float = 15.0
var attack_range: float = 50.0
var attack_cooldown: float = 0.5
var attack_timer: float = 0.0
var max_health: float = 100.0
var current_health: float = 100.0
var invincible: bool = false
var invincible_time: float = 0.5
var invincible_timer: float = 0.0
var is_dead: bool = false

func _ready():
	add_to_group("player")
	# Настройка анимаций (как раньше)
	var frames = SpriteFrames.new()
	
	# Загружаем звук шагов один раз
	step_sfx = load("res://assets/music/walk.mp3")
	
	# Создаём плеер специально для шагов
	step_player = AudioStreamPlayer.new()
	step_player.bus = "SFX"
	step_player.stream = step_sfx
	step_player.volume_db = linear_to_db(0.3)
	add_child(step_player)

	# Ходьба (pers.png)
	var walk_sheet = load("res://assets/sprites/main_person/pers.png")
	if walk_sheet:
		var w = walk_sheet.get_width() / 3
		var h = walk_sheet.get_height() / 4
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
		var ih = idle_sheet.get_height()
		frames.add_animation("idle")
		for col in range(2):
			var rect = Rect2(col * iw, 0, iw, ih)
			var tex = AtlasTexture.new()
			tex.atlas = idle_sheet
			tex.region = rect
			frames.add_frame("idle", tex)
	else:
		if frames.has_animation("walk_down"):
			var first_frame = frames.get_frame("walk_down", 0)
			frames.add_animation("idle")
			frames.add_frame("idle", first_frame)

	var anim_speed = 60.0 / 8.0   # 7.5 fps
	for anim_name in frames.get_animation_names():
		frames.set_animation_speed(anim_name, anim_speed)

	anim.sprite_frames = frames
	anim.play("idle")
	
	# Генерируем анимацию атаки
	AnimationGenerator.generate_player_attack_frames(anim.sprite_frames)


func set_map_info(width: int, height: int, collisions: Array, tsize: int, teleports: Array = []):
	map_width = width
	map_height = height
	map_collisions = collisions
	tile_size = tsize
	teleport_points = teleports


func _physics_process(delta):
	if is_dead:
		return
	handle_input()
	update_animation()
	check_near_teleport()

	if Input.is_action_just_pressed("interact"):
		try_teleport()
		
	# Звук шагов
	if direction != Vector2.ZERO:
		step_timer -= delta
		if step_timer <= 0:
			step_timer = step_interval
			# Перезапускаем звук с начала
			if step_player.playing:
				step_player.stop()
			step_player.play()
	else:
		# Останавливаем звук при бездействии
		if step_player.playing:
			step_player.stop()
		step_timer = 0.0

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
	
	if Input.is_action_just_pressed("attack") and not is_attacking and attack_timer <= 0:
		start_attack()
	
	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			is_attacking = false
			attack_timer = attack_cooldown
	else:
		attack_timer -= delta
		
	if invincible:
		invincible_timer -= delta
		if invincible_timer <= 0:
			invincible = false
			modulate = Color.WHITE

func handle_input():
	if Input.is_action_just_pressed("interact"):
		try_heal()
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction.length() > 0:
		direction = direction.normalized()
	

func try_heal():
	var pickups = get_tree().get_nodes_in_group("pickups")
	for pickup in pickups:
		if pickup.player_nearby:
			heal(pickup.heal_amount)
			pickup.queue_free()
			print("Подобрана хилка! +", pickup.heal_amount, "HP")
			return  # выходим после первой хилки
			
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


func try_teleport():
	# Определяем центр тайла, на котором стоит персонаж
	var sprite_size = anim.sprite_frames.get_frame_texture("idle", 0).get_size()
	var center_x = position.x + sprite_size.x / 2.0
	var center_y = position.y + sprite_size.y / 2.0
	var tile_x = int(center_x / tile_size)
	var tile_y = int(center_y / tile_size)

	for tp in teleport_points:
		if tp.x == tile_x and tp.y == tile_y:
			emit_signal("teleport_attempted", tp.target_map)
			return


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

func check_near_teleport():
	var sprite_size = anim.sprite_frames.get_frame_texture("idle", 0).get_size()
	var center_x = position.x + sprite_size.x / 2.0
	var center_y = position.y + sprite_size.y / 2.0
	var tile_x = int(center_x / tile_size)
	var tile_y = int(center_y / tile_size)

	for tp in teleport_points:
		if tp.x == tile_x and tp.y == tile_y:
			hint_label.visible = true
			hint_label.text = LocalizationManager.get_text("press_e_to_teleport")
			return
	hint_label.visible = false
	
func start_attack():
	is_attacking = true
	# Длительность = количество кадров / скорость анимации
	var attack_frames = anim.sprite_frames.get_frame_count("attack")
	var attack_speed = anim.sprite_frames.get_animation_speed("attack")
	attack_timer = attack_frames / attack_speed  # примерно 0.2 секунды для 2 кадров при скорости 10
	attack_timer = max(attack_timer, 0.5)  # минимум 0.3 секунды
	anim.play("attack")
	
	# Наносим урон ближайшему врагу
	var enemies = get_tree().get_nodes_in_group("enemies")
	var closest_enemy = null
	var closest_dist = attack_range
	
	for enemy in enemies:
		var dist = position.distance_to(enemy.position)
		if dist < closest_dist:
			closest_dist = dist
			closest_enemy = enemy
	
	if closest_enemy and closest_enemy.has_method("take_damage"):
		closest_enemy.take_damage(attack_damage)
		print("Удар по врагу! Урон: ", attack_damage)
		
func take_damage(amount: float):
	if invincible:
		return
	
	current_health -= amount
	print("Игрок получил урон: ", amount, " HP: ", current_health)
	
	if current_health <= 0:
		die()
	
	# Неуязвимость и мигание
	invincible = true
	invincible_timer = invincible_time
	modulate = Color.RED


func die():
	print("Игрок погиб!")
	is_dead = true
	
	# Останавливаем анимацию
	anim.play("idle")
	anim.stop()
	
	# Отключаем коллизию, чтобы враги не толкали труп
	$CollisionShape2D.disabled = true
	
	var death_screen = load("res://scenes/death_screen.tscn").instantiate()
	get_tree().current_scene.add_child(death_screen)
	
func heal(amount: float):
	current_health = min(current_health + amount, max_health)
	print("Игрок вылечен на ", amount, " HP: ", current_health)
