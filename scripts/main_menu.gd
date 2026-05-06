extends Control

@onready var fade_rect: ColorRect = $CanvasLayer/FadeRect

func _ready():
	fade_rect.color = Color.BLACK
	var tween = create_tween()
	tween.tween_property(fade_rect, "color", Color(0, 0, 0, 0), 0.5)
	
	var save_exists = FileAccess.file_exists("user://savegame.dat")
	$VBoxContainer/ContinueButton.visible = save_exists
	
	$VBoxContainer/ContinueButton.pressed.connect(_on_continue)
	$VBoxContainer/NewGameButton.pressed.connect(_on_new_game)
	$VBoxContainer/ExitButton.pressed.connect(_on_exit)


func _on_continue():
	_fade_to_game("test.map")


func _on_new_game():
	_fade_to_game("1.map")


func _on_exit():
	var tween = create_tween()
	tween.tween_property(fade_rect, "color", Color.BLACK, 0.5)
	tween.tween_callback(get_tree().quit)


func _fade_to_game(map_file: String):
	# Сохраняем имя карты в автозагрузку
	SceneManager.pending_map = map_file
	
	var tween = create_tween()
	tween.tween_property(fade_rect, "color", Color.BLACK, 0.3)
	tween.tween_callback(func():
		get_tree().change_scene_to_file("res://scenes/game.tscn")
	)
