extends Control

@onready var fade_rect: ColorRect = $CanvasLayer/FadeRect

func _ready():
	# Fade in при запуске
	fade_rect.color = Color.BLACK
	var tween = create_tween()
	tween.tween_property(fade_rect, "color", Color(0, 0, 0, 0), 0.5)
	
	# Проверяем наличие сохранения
	var save_exists = FileAccess.file_exists("user://savegame.dat")
	$VBoxContainer/ContinueButton.visible = save_exists
	
	$VBoxContainer/ContinueButton.pressed.connect(_on_continue)
	$VBoxContainer/NewGameButton.pressed.connect(_on_new_game)
	$VBoxContainer/ExitButton.pressed.connect(_on_exit)


func set_data(data: Dictionary):
	pass  # Меню не принимает данные


func _on_continue():
	_fade_to_game("1.map")


func _on_new_game():
	_fade_to_game("1.map")


func _on_exit():
	# Fade out и выход
	var tween = create_tween()
	tween.tween_property(fade_rect, "color", Color.BLACK, 0.5)
	tween.tween_callback(SceneManager.quit_game)


func _fade_to_game(map_file: String):
	# Затемняем экран, потом меняем сцену
	var tween = create_tween()
	tween.tween_property(fade_rect, "color", Color.BLACK, 0.3)
	tween.tween_callback(func():
		SceneManager.go_to_game(map_file)
	)
