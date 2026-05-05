extends Node2D

var player_scene = preload("res://scenes/player.tscn")
var pause_menu_scene = preload("res://scenes/pause_menu.tscn")
var current_player = null
var map_container = null

@onready var fade_rect: ColorRect = $CanvasLayer/FadeRect

func _ready():
	fade_rect.visible = false
	# Если SceneManager передал данные
	if has_method("set_data"):
		pass  # вызовется из SceneManager


func set_data(data: Dictionary):
	var map_file = data.get("map_file", "1.map")
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

	var anim_sprite = current_player.get_node("AnimatedSprite2D")
	var sprite_size = Vector2(tsize, tsize)
	if anim_sprite and anim_sprite.sprite_frames:
		var frames = anim_sprite.sprite_frames
		if frames.has_animation("idle"):
			var tex = frames.get_frame_texture("idle", 0)
			if tex is AtlasTexture:
				sprite_size = tex.region.size
			else:
				sprite_size = tex.get_size()

	var entry = map_data.get("entry_point", null)
	if entry != null and entry is Array and entry.size() == 2:
		var px = entry[0] * tsize + tsize / 2.0 - sprite_size.x / 2.0
		var py = entry[1] * tsize + tsize / 2.0 - sprite_size.y / 2.0
		current_player.position = Vector2(px, py)
	else:
		var cx = (map_w * tsize) / 2.0 - sprite_size.x / 2.0
		var cy = (map_h * tsize) / 2.0 - sprite_size.y / 2.0
		current_player.position = Vector2(cx, cy)

	var cam = current_player.get_node_or_null("Camera2D")
	if cam:
		cam.limit_left = 0
		cam.limit_top = 0
		cam.limit_right = map_w * tsize
		cam.limit_bottom = map_h * tsize

	if not current_player.is_connected("teleport_attempted", _on_teleport_attempted):
		current_player.teleport_attempted.connect(_on_teleport_attempted)


func _input(event):
	if event.is_action_pressed("ui_cancel"):  # ESC
		open_pause_menu()


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
