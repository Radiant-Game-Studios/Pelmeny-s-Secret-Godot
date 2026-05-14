extends Control

@onready var fade_rect: ColorRect = $CanvasLayer/FadeRect
@onready var flag_icon: TextureRect = $LanguageButton/FlagIcon

var flag_ru = preload("res://assets/sprites/system/rflag.jpg")
var flag_en = preload("res://assets/sprites/system/usa.jpg")


func _ready():
	AudioManager.play_music(load("res://assets/music/mainmenu.mp3"))
	
	fade_rect.color = Color.BLACK
	var tween = create_tween()
	tween.tween_property(fade_rect, "color", Color(0, 0, 0, 0), 0.5)
	
	# Кнопки
	$VBoxContainer/ContinueButton.visible = FileAccess.file_exists("user://savegame.dat")
	$VBoxContainer/ContinueButton.pressed.connect(_on_continue)
	$VBoxContainer/NewGameButton.pressed.connect(_on_new_game)
	$VBoxContainer/ExitButton.pressed.connect(_on_exit)
	$LanguageButton.pressed.connect(_on_toggle_language)
	
	# Установка текстов кнопок
	_refresh_texts()
	
	# Установка иконки языка
	_update_flag_icon()


func _refresh_texts():
	$VBoxContainer/NewGameButton.text = LocalizationManager.get_text("new_game")
	$VBoxContainer/ContinueButton.text = LocalizationManager.get_text("continue")
	$VBoxContainer/ExitButton.text = LocalizationManager.get_text("exit")


func _update_flag_icon():
	if LocalizationManager.current_language == LocalizationManager.Language.RUSSIAN:
		flag_icon.texture = flag_ru
	else:
		flag_icon.texture = flag_en


func _on_toggle_language():
	LocalizationManager.toggle_language()
	_refresh_texts()
	_update_flag_icon()


func _on_continue():
	_fade_to_game("test.map")


func _on_new_game():
	AudioManager.play_sfx_path("res://assets/sounds/click.mp3")
	_fade_to_game("1.map")


func _on_exit():
	AudioManager.play_sfx_path("res://assets/sounds/click.mp3")
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
