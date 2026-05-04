extends Node2D

func _ready():
	# Загружаем карту, например "test.map"
	var map_scene = MapManager.load_map("1.map")
	if map_scene:
		add_child(map_scene)
		# Здесь позже можно будет разместить игрока по entry_point,
		# но для первого этапа просто убедимся, что карта отображается.
	else:
		print("Не удалось загрузить карту.")
