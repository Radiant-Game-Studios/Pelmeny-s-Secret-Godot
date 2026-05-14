extends CanvasLayer

func _ready():
	# Кнопки
	$VBoxContainer/ContinueButton.pressed.connect(_on_continue)
	$VBoxContainer/SaveButton.pressed.connect(_on_save)
	$VBoxContainer/MainMenuButton.pressed.connect(_on_main_menu)
	$VBoxContainer/ExitButton.pressed.connect(_on_exit)
	
	# Ставим паузу игре
	get_tree().paused = true
	
	# Обрабатываем ESC — тоже выход из паузы
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	#локализация
	$VBoxContainer/ContinueButton.text = LocalizationManager.get_text("continue")
	$VBoxContainer/SaveButton.text = LocalizationManager.get_text("save")
	$VBoxContainer/MainMenuButton.text = LocalizationManager.get_text("main_menu")
	$VBoxContainer/ExitButton.text = LocalizationManager.get_text("exit")

func _input(event):
	if event.is_action_pressed("ui_cancel"):  # ESC
		_on_continue()

func _on_continue():
	AudioManager.play_sfx_path("res://assets/sounds/click.mp3")
	get_tree().paused = false
	queue_free()

func _on_save():
	AudioManager.play_sfx_path("res://assets/sounds/click.mp3")
	print("Игра сохранена!")
	# Здесь будет логика сохранения
	_on_continue()

func _on_main_menu():
	AudioManager.play_sfx_path("res://assets/sounds/click.mp3")
	get_tree().paused = false
	SceneManager.go_to_main_menu()

func _on_exit():
	AudioManager.play_sfx_path("res://assets/sounds/click.mp3")
	get_tree().paused = false
	SceneManager.quit_game()
