extends Node2D

var player_scene = preload("res://scenes/player.tscn")
var current_player = null

func _ready():
	var map_scene = MapManager.load_map("1.map")
	if map_scene:
		add_child(map_scene)

		current_player = player_scene.instantiate()
		add_child(current_player)

		var map_data = map_scene.map_data
		var collisions = map_data.get("collisions", [])
		var map_w = map_data.get("width", 20)
		var map_h = map_data.get("height", 15)
		var tsize = map_data.get("tile_size", 64)
		current_player.set_map_info(map_w, map_h, collisions, tsize)

		# Размер спрайта для начальной позиции
		var sprite = current_player.get_node("Sprite2D")
		var sprite_size = sprite.texture.get_size()
		if sprite.region_enabled:
			sprite_size = sprite.region_rect.size

		var entry = map_data.get("entry_point", null)
		if entry != null and entry is Array and entry.size() == 2:
			var px = entry[0] * tsize + tsize / 2.0 - sprite_size.x / 2.0
			var py = entry[1] * tsize + tsize / 2.0 - sprite_size.y / 2.0
			current_player.position = Vector2(px, py)
		else:
			var cx = (map_w * tsize) / 2.0 - sprite_size.x / 2.0
			var cy = (map_h * tsize) / 2.0 - sprite_size.y / 2.0
			current_player.position = Vector2(cx, cy)

		# Ограничение камеры
		var cam = current_player.get_node_or_null("Camera2D")
		if cam:
			cam.limit_left = 0
			cam.limit_top = 0
			cam.limit_right = map_w * tsize
			cam.limit_bottom = map_h * tsize
	else:
		push_error("Не удалось загрузить карту.")
