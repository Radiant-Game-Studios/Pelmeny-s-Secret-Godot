extends Node2D

var player_scene = preload("res://scenes/player.tscn")
var pause_menu_scene = preload("res://scenes/pause_menu.tscn")
var current_player = null
var map_container = null

# Новое: переменные отладки
var show_debug_info: bool = false
var show_collisions: bool = false

@onready var fade_rect: ColorRect = $CanvasLayer/FadeRect
@onready var info_panel: ColorRect = $DebugCanvas/InfoPanel
@onready var info_label: Label = $DebugCanvas/InfoPanel/InfoLabel
@onready var debug_draw: Node2D = $DebugDraw


func _ready():
	fade_rect.visible = true
	fade_rect.color = Color.BLACK
	
	# Новое: начальное состояние отладки
	info_panel.visible = true
	debug_draw.show_collisions = false
	show_debug_info = true
	
	var map_file = SceneManager.pending_map
	if map_file == "":
		map_file = "test.map"
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	load_map(map_file)


func load_map(map_name: String):
	if map_container:
		map_container.queue_free()
		map_container = null
	if current_player:
		current_player.queue_free()
		current_player = null

	var new_map = MapManager.load_map(map_name)
	if new_map == null:
		push_error("Не удалось загрузить карту: " + map_name)
		return

	map_container = new_map
	add_child(map_container)
	move_child(map_container, 0)
	
	spawn_player(map_container.map_data)


func spawn_player(map_data: Dictionary):
	current_player = player_scene.instantiate()
	add_child(current_player)

	var collisions = map_data.get("collisions", [])
	var map_w = map_data.get("width", 20)
	var map_h = map_data.get("height", 15)
	var tsize = map_data.get("tile_size", 64)
	var teleports = map_data.get("teleport_points", [])
	current_player.set_map_info(map_w, map_h, collisions, tsize, teleports)

	# Размер спрайта
	var anim_sprite = current_player.get_node("AnimatedSprite2D")
	var sprite_size = Vector2(tsize, tsize)
	if anim_sprite and anim_sprite.sprite_frames:
		var frames = anim_sprite.sprite_frames
		if frames.has_animation("idle"):
			var tex = frames.get_frame_texture("idle", 0)
			if tex:
				sprite_size = tex.get_size()

	# Позиция игрока
	var entry = map_data.get("entry_point", null)
	if entry != null and entry is Array and entry.size() == 2:
		var px = entry[0] * tsize + tsize / 2.0 - sprite_size.x / 2.0
		var py = entry[1] * tsize + tsize / 2.0 - sprite_size.y / 2.0
		current_player.position = Vector2(px, py)
	else:
		var cx = (map_w * tsize) / 2.0 - sprite_size.x / 2.0
		var cy = (map_h * tsize) / 2.0 - sprite_size.y / 2.0
		current_player.position = Vector2(cx, cy)

	# Настройка камеры
	var cam = current_player.get_node_or_null("Camera2D")
	if cam:
		cam.limit_left = 0
		cam.limit_top = 0
		cam.limit_right = map_w * tsize
		cam.limit_bottom = map_h * tsize
		cam.position = current_player.position + sprite_size / 2.0 - get_viewport().get_visible_rect().size / 2.0
		cam.reset_smoothing()

	# Новое: передаём данные коллизий в отладочный узел
	if debug_draw:
		debug_draw.collision_rects = collisions
		debug_draw.tile_size = tsize

	if not current_player.is_connected("teleport_attempted", _on_teleport_attempted):
		current_player.teleport_attempted.connect(_on_teleport_attempted)
	
	# Fade in
	fade_rect.color = Color.BLACK
	fade_rect.visible = true
	var tween = create_tween()
	tween.tween_property(fade_rect, "color", Color(0, 0, 0, 0), 0.5)
	tween.tween_callback(func():
		fade_rect.visible = false
	)


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		open_pause_menu()
		return
	# Новое: переключение отладки
	if event.is_action_pressed("toggle_debug"):
		show_debug_info = !show_debug_info
		info_panel.visible = show_debug_info
	if event.is_action_pressed("toggle_collisions"):
		show_collisions = !show_collisions
		debug_draw.show_collisions = show_collisions
		debug_draw.queue_redraw()


func _physics_process(delta):
	# Новое: обновление текста отладки и хитбокса игрока
	if show_debug_info:
		_update_debug_text()
	
	if show_collisions and current_player:
		_update_collision_debug()


func _update_debug_text():
	var fps = Engine.get_frames_per_second()
	var text = "FPS: %d\n\n" % fps
	text += "Управление:\n"
	text += "Стрелки/WASD - движение\n"
	text += "E - телепорт\n"
	text += "C - коллизии\n"
	text += "H - скрыть подсказку\n"
	text += "ESC - меню"
	info_label.text = text


func _update_collision_debug():
	# Обновляем хитбокс игрока в системе координат карты
	var shape: RectangleShape2D = current_player.get_node("CollisionShape2D").shape
	var col_pos = current_player.get_node("CollisionShape2D").position
	debug_draw.player_hitbox = Rect2(current_player.position + col_pos, shape.size)
	debug_draw.queue_redraw()


func open_pause_menu():
	var pause_menu = pause_menu_scene.instantiate()
	add_child(pause_menu)


func _on_teleport_attempted(target_map: String):
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.visible = true

	var tween = create_tween()
	tween.tween_property(fade_rect, "color", Color.BLACK, 0.3)
	tween.tween_callback(func():
		load_map(target_map + ".map")
		fade_rect.color = Color.BLACK
		var tween2 = create_tween()
		tween2.tween_property(fade_rect, "color", Color(0, 0, 0, 0), 0.3)
		tween2.tween_callback(func():
			fade_rect.visible = false
		)
	)
