extends CanvasLayer

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	$VBoxContainer/RetryButton.text = LocalizationManager.get_text("retry")
	$VBoxContainer/MenuButton.text = LocalizationManager.get_text("main_menu")
	$VBoxContainer/ExitButton.text = LocalizationManager.get_text("exit")
	$VBoxContainer/TitleLabel.text = LocalizationManager.get_text("you_died")
	
	$VBoxContainer/RetryButton.pressed.connect(_on_retry)
	$VBoxContainer/MenuButton.pressed.connect(_on_menu)
	$VBoxContainer/ExitButton.pressed.connect(_on_exit)


func _on_retry():
	SceneManager.pending_map = SceneManager.pending_map  # та же карта
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_menu():
	SceneManager.go_to_main_menu()


func _on_exit():
	get_tree().quit()
