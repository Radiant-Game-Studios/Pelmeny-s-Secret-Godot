extends CanvasLayer

var attack_pressed: bool = false
var interact_pressed: bool = false
var pause_pressed: bool = false


func _ready():
	visible = false
	
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		visible = true
	
	$AttackButton.button_down.connect(func(): 
		attack_pressed = true
		print("АТАКА зажата")
	)
	$AttackButton.button_up.connect(func(): 
		attack_pressed = false
		print("АТАКА отпущена")
	)
	$InteractButton.button_down.connect(func(): 
		interact_pressed = true
		print("E зажата")
	)
	$InteractButton.button_up.connect(func(): 
		interact_pressed = false
		print("E отпущена")
	)
	$PauseButton.button_down.connect(func(): 
		pause_pressed = true
		print("ПАУЗА зажата")
	)
	$PauseButton.button_up.connect(func(): 
		pause_pressed = false
		print("ПАУЗА отпущена")
	)
	
	# Подключаемся к сигналам диалоговой системы
	var dialog_sys = get_tree().get_first_node_in_group("dialog_system")
	if dialog_sys:
		dialog_sys.dialog_started.connect(_on_dialog_started)
		dialog_sys.dialog_ended.connect(_on_dialog_ended)

func _on_dialog_started():
	# Скрываем атаку и паузу, оставляем только E
	$"Virtual Joystick".visible = false
	$AttackButton.visible = false
	$PauseButton.visible = false
	# InteractButton остаётся видимой
	
func _on_dialog_ended():
	# Восстанавливаем все кнопки
	$"Virtual Joystick".visible = true
	$AttackButton.visible = true
	$PauseButton.visible = true

func toggle_visibility():
	visible = !visible
