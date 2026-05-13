extends Control

@onready var fade_rect: ColorRect = $CanvasLayer/FadeRect

func _ready():
	fade_rect.color = Color.BLACK
	
	var tween = create_tween()
	tween.tween_property(fade_rect, "color", Color(0, 0, 0, 0), 1.0)
	tween.tween_interval(0.5)
	tween.tween_property(fade_rect, "color", Color.BLACK, 1.0)
	tween.tween_callback(_go_to_menu)
	
	$Label.text = LocalizationManager.get_text("splash_subtitle")


func _go_to_menu():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _input(event):
	if event is InputEventKey or event is InputEventMouseButton:
		if event.is_pressed():
			get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
