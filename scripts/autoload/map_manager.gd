extends Node

var current_scene: Node = null
var pending_map: String = "test.map"


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS


static func data_path() -> String:
	if OS.has_feature("editor"):
		return ProjectSettings.globalize_path("res://Maps")
	else:
		return OS.get_executable_path().get_base_dir().path_join("Maps")


func load_map(map_filename: String) -> Node:
	var full_path = data_path().path_join(map_filename)
	
	if not FileAccess.file_exists(full_path):
		push_error("Файл не найден: " + full_path)
		return null
	
	# Проверяем первую строку — не кат-сцена ли это
	var file = FileAccess.open(full_path, FileAccess.READ)
	var first_line = file.get_line().strip_edges()
	
	if first_line == "CUT_SCENE":
		# Это кат-сцена
		var video_file = file.get_line().strip_edges()
		var next_map = file.get_line().strip_edges()
		file.close()
		
		print("Обнаружена кат-сцена: видео=", video_file, " карта=", next_map)
		
		# Создаём сцену кат-сцены
		var cut_scene = load("res://scenes/cut_scene.tscn").instantiate()
		cut_scene.setup(video_file, next_map)
		return cut_scene
	else:
		# Это обычная карта — читаем JSON
		file.close()
		return _load_json_map(full_path)


func _load_json_map(full_path: String) -> Node:
	var file = FileAccess.open(full_path, FileAccess.READ)
	var json_text = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_text)
	if error != OK:
		push_error("Ошибка парсинга JSON: ", json.get_error_message())
		return null

	var data = json.data
	var map_container = preload("res://scenes/map_container.tscn").instantiate()
	map_container.setup(data, full_path.get_base_dir())
	return map_container


func go_to_game(map_file: String = "test.map"):
	pending_map = map_file
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func go_to_main_menu():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func quit_game():
	get_tree().quit()
