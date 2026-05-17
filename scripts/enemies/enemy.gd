extends CharacterBody2D

@export var enemy_id: String = ""
@export var max_health: float = 30.0
@export var speed: float = 80.0
@export var damage: float = 10.0
@export var attack_range: float = 50.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var visibility_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var health_bar: ProgressBar = $HealthBar

var player: Node = null
var current_health: float
var is_active: bool = false
var is_attacking: bool = false
var direction: Vector2 = Vector2.ZERO
var attack_cooldown: float = 1.0
var attack_timer: float = 0.0


func _ready():
	add_to_group("enemies")
	current_health = max_health
	
	# Загружаем тип врага из реестра
	var type = EnemyRegistry.get_enemy_type(enemy_id)
	if type:
		max_health = type.max_health
		speed = type.speed
		damage = type.damage
		attack_range = type.attack_range
		current_health = max_health
	
	# Генерируем тестовые анимации
	generate_animations()
	
	# Подключаем сигнал видимости
	if visibility_notifier:
		visibility_notifier.screen_entered.connect(_on_screen_entered)
		visibility_notifier.screen_exited.connect(_on_screen_exited)
		
	update_health_bar()


func generate_animations():
	var color = Color.GREEN
	match enemy_id:
		"slime":
			color = Color.GREEN
		"shit":
			color = Color.GRAY
		_:
			color = Color.RED
	
	var frames = AnimationGenerator.generate_enemy_frames(Vector2(48, 48), color)
	animated_sprite.sprite_frames = frames
	animated_sprite.play("idle")


func _on_screen_entered():
	is_active = true
	print(enemy_id, " активирован")


func _on_screen_exited():
	is_active = false
	print(enemy_id, " деактивирован")


func _physics_process(delta):
	if not is_active:
		return
	
	# Если игрок мёртв — ничего не делаем
	if player and player.has_method("is_dead") and player.is_dead:
		animated_sprite.play("idle")
		return
		
	attack_timer -= delta
	
	# Ищем игрока
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		if player == null:
			return
	
	var distance = position.distance_to(player.position)
	
	if distance <= attack_range:
		# Режим атаки
		if attack_timer <= 0:
			attack_timer = attack_cooldown
			animated_sprite.play("attack")
			if player and player.has_method("take_damage"):
				player.take_damage(damage)
				print(enemy_id, " атакует игрока! Урон: ", damage)
	else:
		# Режим преследования
		direction = (player.position - position).normalized()
		animated_sprite.play("run")
		position += direction * speed * delta
		if direction.x < 0:
			animated_sprite.flip_h = true
		else:
			animated_sprite.flip_h = false


func take_damage(amount: float):
	current_health -= amount
	update_health_bar()
	if current_health <= 0:
		die()


func die():
	# Спавним хилку
	var pickup_scene = load("res://scenes/health_pickup.tscn")
	var pickup = pickup_scene.instantiate()
	pickup.position = position
	get_parent().add_child(pickup)
	
	queue_free()
	
func update_health_bar():
	if health_bar:
		var ratio = current_health / max_health
		health_bar.value = ratio * 100
		
		var style = health_bar.get_theme_stylebox("fill", "ProgressBar")
		if style is StyleBoxFlat:
			if ratio > 0.6:
				style.bg_color = Color.GREEN
			elif ratio > 0.3:
				style.bg_color = Color.YELLOW
			else:
				style.bg_color = Color.RED
