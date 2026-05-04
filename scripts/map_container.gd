extends Node2D

var map_data: Dictionary = {}
var custom_tiles_path: String

func setup(data: Dictionary, base_path: String) -> void:
	var layer1: TileMapLayer = get_node_or_null("Layer1Background") as TileMapLayer
	var layer2: TileMapLayer = get_node_or_null("Layer2Objects") as TileMapLayer
	var layer3: TileMapLayer = get_node_or_null("Layer3Overlay") as TileMapLayer

	if not layer1 or not layer2 or not layer3:
		push_error("Не найдены TileMapLayer ноды в сцене map_container.tscn. Проверьте имена.")
		return

	map_data = data
	custom_tiles_path = base_path.path_join("custom_tiles")
	var tile_size: int = data.get("tile_size", 64)
	print("=== Загрузка карты: tile_size = ", tile_size)

	var tile_set = TileSet.new()
	tile_set.tile_size = Vector2i(tile_size, tile_size)
	var type_to_source = {}

	# 1. Стандартные тайлы (0–10)
	for tile_type in range(0, 11):
		var texture = generate_base_tile_texture(tile_type, tile_size)
		var source_id = tile_set.add_source(TileSetAtlasSource.new())
		if source_id == -1:
			push_error("Не удалось добавить стандартный источник " + str(tile_type))
			continue
		var atlas = tile_set.get_source(source_id)
		atlas.texture = texture
		atlas.texture_region_size = Vector2i(tile_size, tile_size)
		atlas.create_tile(Vector2i.ZERO)
		type_to_source[tile_type] = source_id
		print("  Стандартный тайл ", tile_type, " -> источник ", source_id,
				" размер текстуры ", texture.get_size(), " регион ", atlas.texture_region_size)

	# 2. Кастомные тайлы (начиная с 11)
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
				push_error("Не удалось загрузить кастомный тайл: " + full_path)
				continue
			if image.get_width() != tile_size or image.get_height() != tile_size:
				print("  Ресайз ", file, " с ", image.get_size(), " до ", tile_size)
				image.resize(tile_size, tile_size, Image.INTERPOLATE_NEAREST)
			var texture = ImageTexture.create_from_image(image)
			var source_id = tile_set.add_source(TileSetAtlasSource.new())
			if source_id == -1:
				push_error("Не удалось добавить кастомный источник для " + file)
				continue
			var atlas = tile_set.get_source(source_id)
			atlas.texture = texture
			atlas.texture_region_size = Vector2i(tile_size, tile_size)
			atlas.create_tile(Vector2i.ZERO)
			type_to_source[id_offset] = source_id
			print("  Кастомный тайл ", file, " -> ID ", id_offset, " источник ", source_id,
					" размер ", atlas.texture_region_size)
			id_offset += 1
	else:
		print("Папка с кастомными тайлами не найдена: ", custom_tiles_path)

	layer1.tile_set = tile_set
	layer2.tile_set = tile_set
	layer3.tile_set = tile_set

	fill_layer(layer1, data.get("layer1_tiles", []), type_to_source)
	fill_layer(layer2, data.get("layer2_tiles", []), type_to_source)
	fill_layer(layer3, data.get("layer3_tiles", []), type_to_source)
	print("=== Карта загружена ===")


# Вспомогательные функции рисования
func fill_circle(image: Image, center_x: int, center_y: int, radius: int, color: Color) -> void:
	for y in range(max(0, center_y - radius), min(image.get_height(), center_y + radius + 1)):
		for x in range(max(0, center_x - radius), min(image.get_width(), center_x + radius + 1)):
			var dist_sq = (x - center_x) ** 2 + (y - center_y) ** 2
			if dist_sq <= radius ** 2:
				image.set_pixel(x, y, color)

func fill_ellipse(image: Image, center_x: int, center_y: int, a: float, b: float, color: Color) -> void:
	for y in range(max(0, int(center_y - b)), min(image.get_height(), int(center_y + b + 1))):
		for x in range(max(0, int(center_x - a)), min(image.get_width(), int(center_x + a + 1))):
			if a > 0 and b > 0:
				var dx = float(x - center_x)
				var dy = float(y - center_y)
				if (dx * dx) / (a * a) + (dy * dy) / (b * b) <= 1.0:
					image.set_pixel(x, y, color)

# Генерация текстуры стандартного тайла
func generate_base_tile_texture(tile_type: int, tile_size: int) -> ImageTexture:
	var colors = {
		0: Color.GREEN,
		1: Color.GRAY,
		2: Color.DODGER_BLUE,
		3: Color.BURLYWOOD,
		4: Color.GREEN,
		5: Color.GRAY,
		6: Color.GREEN,
		7: Color.DARK_GRAY,
		8: Color.DARK_GREEN,
		9: Color.CRIMSON,
		10: Color.ALICE_BLUE
	}
	var image = Image.create(tile_size, tile_size, false, Image.FORMAT_RGBA8)
	image.fill(colors.get(tile_type, Color.PINK))

	# Сетка
	#for i in range(0, tile_size, 4):
	#	image.fill_rect(Rect2i(i, 0, 1, tile_size), Color(0,0,0,0.1))
	#	image.fill_rect(Rect2i(0, i, tile_size, 1), Color(0,0,0,0.1))

	# Особые тайлы
	match tile_type:
		4:  # дерево
			image.fill(Color.GREEN)
			image.fill_rect(Rect2i(tile_size/2 - 4, tile_size/2, 8, tile_size/2), Color.SADDLE_BROWN)
			fill_circle(image, tile_size/2, tile_size/2 - 8, tile_size/3, Color.FOREST_GREEN)
		5:  # камень
			image.fill(Color.GRAY)
			fill_ellipse(image, tile_size/2, tile_size/2, 10, 6, Color.DIM_GRAY)
		6:  # цветок
			image.fill(Color.GREEN)
			for i in range(2):
				for j in range(2):
					var cx = 10 + i * 22
					var cy = 10 + j * 22
					fill_circle(image, cx, cy, 5, Color.RED if (i+j) % 2 == 0 else Color.YELLOW)
	return ImageTexture.create_from_image(image)

# Заполнение слоя тайлами
func fill_layer(layer: TileMapLayer, tiles: Array, type_to_source: Dictionary) -> void:
	if tiles.is_empty():
		return
	for tile in tiles:
		if tile is Array:
			var x = tile[0]
			var y = tile[1]
			var ttype = tile[2]
			_set_cell(layer, x, y, ttype, type_to_source)
		elif tile is Dictionary:
			_set_cell(layer, tile.x, tile.y, tile.tile_type, type_to_source)

func _set_cell(layer: TileMapLayer, x: int, y: int, tile_type: int, type_to_source: Dictionary) -> void:
	if not type_to_source.has(tile_type):
		return
	var source_id = type_to_source[tile_type]
	layer.set_cell(Vector2i(x, y), source_id, Vector2i.ZERO)
