extends Node

var current_scene: Node = null
var scene_history: Array = []

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Ждём первый кадр, потом проверяем
	await get_tree().process_frame
	
	# Если главная сцена уже загружена (main_menu.tscn), используем её как current_scene
	if current_scene == null:
		var root_children = get_tree().root.get_children()
		for child in root_children:
			if child.scene_file_path == "res://scenes/main_menu.tscn":
				current_scene = child
				break
	
	# Если всё равно нет сцены (на всякий случай) — загружаем меню
	if current_scene == null:
		change_scene("res://scenes/main_menu.tscn")

func change_scene(scene_path: String, data: Dictionary = {}):
	if current_scene:
		current_scene.queue_free()
		current_scene = null
	
	# Небольшая задержка перед загрузкой новой сцены
	await get_tree().process_frame
	
	var new_scene = load(scene_path).instantiate()
	get_tree().root.add_child(new_scene)
	current_scene = new_scene
	
	if data.size() > 0 and new_scene.has_method("set_data"):
		new_scene.set_data(data)

func push_scene(scene_path: String, data: Dictionary = {}):
	"""Сохраняем текущую сцену в историю и открываем новую"""
	if current_scene:
		scene_history.append({"path": current_scene.scene_file_path, "scene": current_scene})
		get_tree().root.remove_child(current_scene)
	
	var new_scene = load(scene_path).instantiate()
	get_tree().root.add_child(new_scene)
	current_scene = new_scene
	
	if data.size() > 0 and new_scene.has_method("set_data"):
		new_scene.set_data(data)

func pop_scene():
	"""Возвращаемся к предыдущей сцене"""
	if scene_history.size() > 0:
		if current_scene:
			current_scene.queue_free()
		
		var prev = scene_history.pop_back()
		get_tree().root.add_child(prev["scene"])
		current_scene = prev["scene"]

func go_to_game(map_file: String = "1.map"):
	change_scene("res://scenes/game.tscn", {"map_file": map_file})

func go_to_main_menu():
	scene_history.clear()
	change_scene("res://scenes/main_menu.tscn")

func quit_game():
	get_tree().quit()
