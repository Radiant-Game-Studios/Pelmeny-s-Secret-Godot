extends Node

var enemy_types: Dictionary = {}

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Загружаем все .tres из папки enemies
	var dir = DirAccess.open("res://resources/enemies/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var res = load("res://resources/enemies/" + file_name)
				if res is EnemyType:
					enemy_types[res.enemy_id] = res
			file_name = dir.get_next()
		dir.list_dir_end()

func get_enemy_type(id: String) -> EnemyType:
	return enemy_types.get(id)
