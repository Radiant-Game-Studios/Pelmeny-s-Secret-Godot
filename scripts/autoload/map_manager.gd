extends Node

# Префикс путей для внешних данных.
# В редакторе всё лежит в res://Maps/, в экспортированной игре Maps будет рядом с .exe.
# Мы всегда будем получать путь к папке с картами через глобализацию.
static func data_path() -> String:
	if OS.has_feature("editor"):
		# В редакторе используем проектную папку
		return ProjectSettings.globalize_path("res://Maps")
	else:
		# В игре – папка рядом с исполняемым файлом
		return OS.get_executable_path().get_base_dir().path_join("Maps")

# Загружает .map файл и возвращает PackedScene (игровую сцену), либо null при ошибке.
func load_map(map_filename: String) -> Node:
	var full_path = data_path().path_join(map_filename)
	if not FileAccess.file_exists(full_path):
		push_error("Файл карты не найден: " + full_path)
		return null

	var file = FileAccess.open(full_path, FileAccess.READ)
	var json_text = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_text)
	if error != OK:
		push_error("Ошибка парсинга JSON: ", json.get_error_message())
		return null

	var data = json.data
	var map_data = {
		"width": data.get("width", 20),
		"height": data.get("height", 15),
		"tile_size": data.get("tile_size", 64),
		"layer1_tiles": data.get("layer1_tiles", []),
		"layer2_tiles": data.get("layer2_tiles", []),
		"layer3_tiles": data.get("layer3_tiles", []),
		"tiles": data.get("tiles", []),        # для обратной совместимости, если нет слоёв
		"collisions": data.get("collisions", []),
		"entry_point": data.get("entry_point", null),
		"teleport_points": data.get("teleport_points", [])
	}

	# Если слои не заданы, используем общий список tiles как слой 1
	if map_data.layer1_tiles.is_empty() and map_data.layer2_tiles.is_empty() and map_data.layer3_tiles.is_empty():
		if not map_data.tiles.is_empty():
			map_data.layer1_tiles = map_data.tiles.duplicate()
		else:
			# Пустая карта
			pass

	# Создаём новую сцену, которая будет содержать карту
	var map_scene = preload("res://scenes/map_container.tscn").instantiate()
	map_scene.setup(map_data, full_path.get_base_dir())
	return map_scene
