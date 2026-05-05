extends Control

func _ready():
	# Проверяем наличие сохранения
	var save_exists = FileAccess.file_exists("user://savegame.dat")
	$VBoxContainer/ContinueButton.visible = save_exists
	
	$VBoxContainer/ContinueButton.pressed.connect(_on_continue)
	$VBoxContainer/NewGameButton.pressed.connect(_on_new_game)
	$VBoxContainer/ExitButton.pressed.connect(_on_exit)

func set_data(data: Dictionary):
	pass  # Меню не принимает данные

func _on_continue():
	print("Загрузка сохранения...")
	# Пока нет сохранений — просто начинаем новую игру
	SceneManager.go_to_game("test.map")

func _on_new_game():
	print("Новая игра")
	SceneManager.go_to_game("1.map")

func _on_exit():
	SceneManager.quit_game()
