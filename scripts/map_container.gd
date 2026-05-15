extends Node2D

var map_data: Dictionary = {}
var custom_tiles_path: String

func setup(data: Dictionary, base_path: String) -> void:
	var layer1: TileMapLayer = get_node_or_null("Layer1Background") as TileMapLayer
	var layer2: TileMapLayer = get_node_or_null("Layer2Objects") as TileMapLayer
	var layer3: TileMapLayer = get_node_or_null("Layer3Overlay") as TileMapLayer

	if not layer1:
		push_error("Layer1Background не найден!")
		return

	map_data = data
	custom_tiles_path = base_path.path_join("custom_tiles")
	var tile_size: int = data.get("tile_size", 64)
	print("=== Загрузка карты: tile_size = ", tile_size)

	var tile_set = TileSet.new()
	tile_set.tile_size = Vector2i(tile_size, tile_size)
	var type_to_source = {}

	# Стандартные тайлы (0–10)
	for tile_type in range(0, 11):
		var texture = generate_base_tile_texture(tile_type, tile_size)
		var source_id = tile_set.add_source(TileSetAtlasSource.new())
		if source_id == -1:
			continue
		var atlas = tile_set.get_source(source_id)
		atlas.texture = texture
		atlas.texture_region_size = Vector2i(tile_size, tile_size)
		atlas.create_tile(Vector2i.ZERO)
		type_to_source[tile_type] = source_id

	# Кастомные тайлы (начиная с 11)
	var custom_start_id = 11
	if DirAccess.dir_exists_absolute(custom_tiles_path):
		var dir = DirAccess.open(custom_tiles_path)
		dir.list_dir_begin()
		var file_list = []
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.get_extension().to_lower() in ["png", "jpg", "jpeg", "bmp"]:
				file_list.append(file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
		file_list.sort()
		
		var id_offset = custom_start_id
		for file in file_list:
			var full_path = custom_tiles_path.path_join(file)
			var image = Image.load_from_file(full_path)
			if image == null:
				continue
			if image.get_width() != tile_size or image.get_height() != tile_size:
				image.resize(tile_size, tile_size, Image.INTERPOLATE_NEAREST)
			var texture = ImageTexture.create_from_image(image)
			var source_id = tile_set.add_source(TileSetAtlasSource.new())
			if source_id == -1:
				continue
			var atlas = tile_set.get_source(source_id)
			atlas.texture = texture
			atlas.texture_region_size = Vector2i(tile_size, tile_size)
			atlas.create_tile(Vector2i.ZERO)
			type_to_source[id_offset] = source_id
			id_offset += 1

	# Назначаем слоям
	if layer1:
		layer1.tile_set = tile_set
		fill_layer(layer1, data.get("layer1_tiles", []), type_to_source)
	if layer2:
		layer2.tile_set = tile_set
		fill_layer(layer2, data.get("layer2_tiles", []), type_to_source)
	if layer3:
		layer3.tile_set = tile_set
		fill_layer(layer3, data.get("layer3_tiles", []), type_to_source)
		
	# 3. Диалоговые триггеры
	var trigger_scene = load("res://scenes/dialog_trigger.tscn")
	var tile_size_int: int = int(tile_size)
	for dt in data.get("dialog_triggers", []):
		var trigger = trigger_scene.instantiate()
		trigger.dialog_id = dt.get("dialog_id", "")
		trigger.position = Vector2(dt.get("x", 0) * tile_size_int + tile_size_int/2,
								   dt.get("y", 0) * tile_size_int + tile_size_int/2)
		# Подгоняем коллизию под размер тайла (если не задано)
		var col_shape = trigger.get_node("CollisionShape2D")
		if col_shape and col_shape.shape:
			col_shape.shape.extents = Vector2(tile_size_int/2, tile_size_int/2)
		add_child(trigger)
		print("Добавлен триггер: ", trigger.dialog_id, " на позиции ", trigger.position)
		
	print("Всего диалоговых триггеров в .map: ", data.get("dialog_triggers", []).size())
	
	print("=== Карта загружена ===")


func generate_base_tile_texture(tile_type: int, tile_size: int) -> ImageTexture:
	var image = Image.create(tile_size, tile_size, false, Image.FORMAT_RGBA8)
	
	var colors = {
		0: Color(0.133, 0.545, 0.133, 1.0),
		1: Color(0.502, 0.502, 0.502, 1.0),
		2: Color(0.251, 0.643, 0.875, 1.0),
		3: Color(0.929, 0.788, 0.686, 1.0),
		4: Color(0.133, 0.545, 0.133, 1.0),
		5: Color(0.502, 0.502, 0.502, 1.0),
		6: Color(0.133, 0.545, 0.133, 1.0),
		7: Color(0.663, 0.663, 0.663, 1.0),
		8: Color(0.098, 0.314, 0.098, 1.0),
		9: Color(0.863, 0.078, 0.235, 1.0),
		10: Color(0.941, 0.973, 1.0, 1.0),
	}
	
	image.fill(colors.get(tile_type, Color.PINK))

	for i in range(0, tile_size, 48):
		image.fill_rect(Rect2i(i, 0, 1, tile_size), Color(0, 0, 0, 0.1))
		image.fill_rect(Rect2i(0, i, tile_size, 1), Color(0, 0, 0, 0.1))

	match tile_type:
		4:
			image.fill(Color(0.133, 0.545, 0.133, 1.0))
			image.fill_rect(Rect2i(tile_size/2 - 4, tile_size/2, 8, tile_size/2), Color(0.545, 0.271, 0.075, 1.0))
			fill_circle(image, tile_size/2, tile_size/2 - 8, tile_size/3, Color(0.133, 0.545, 0.133, 1.0))
		5:
			image.fill(Color(0.502, 0.502, 0.502, 1.0))
			fill_ellipse(image, tile_size/2, tile_size/2, 10, 6, Color(0.412, 0.412, 0.412, 1.0))
		6:
			image.fill(Color(0.133, 0.545, 0.133, 1.0))
			for i in range(2):
				for j in range(2):
					var cx = 10 + i * 22
					var cy = 10 + j * 22
					var c = Color.RED if (i+j) % 2 == 0 else Color.YELLOW
					c.a = 1.0
					fill_circle(image, cx, cy, 5, c)
	
	return ImageTexture.create_from_image(image)


func fill_circle(image: Image, center_x: int, center_y: int, radius: int, color: Color) -> void:
	for y in range(max(0, center_y - radius), min(image.get_height(), center_y + radius + 1)):
		for x in range(max(0, center_x - radius), min(image.get_width(), center_x + radius + 1)):
			if (x - center_x) ** 2 + (y - center_y) ** 2 <= radius ** 2:
				image.set_pixel(x, y, color)

func fill_ellipse(image: Image, center_x: int, center_y: int, a: float, b: float, color: Color) -> void:
	for y in range(max(0, int(center_y - b)), min(image.get_height(), int(center_y + b + 1))):
		for x in range(max(0, int(center_x - a)), min(image.get_width(), int(center_x + a + 1))):
			if a > 0 and b > 0:
				var dx = float(x - center_x)
				var dy = float(y - center_y)
				if (dx*dx)/(a*a) + (dy*dy)/(b*b) <= 1.0:
					image.set_pixel(x, y, color)


func fill_layer(layer: TileMapLayer, tiles: Array, type_to_source: Dictionary) -> void:
	if tiles.is_empty():
		return
	for tile in tiles:
		if tile is Array:
			_set_cell(layer, tile[0], tile[1], tile[2], type_to_source)
		elif tile is Dictionary:
			_set_cell(layer, tile.x, tile.y, tile.tile_type, type_to_source)

func _set_cell(layer: TileMapLayer, x: int, y: int, tile_type: int, type_to_source: Dictionary) -> void:
	if not type_to_source.has(tile_type):
		return
	layer.set_cell(Vector2i(x, y), type_to_source[tile_type], Vector2i.ZERO)
