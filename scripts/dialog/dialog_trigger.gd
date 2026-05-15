extends Area2D

@export var dialog_id: String = ""
var chain: DialogChain = null
var player_in_range: bool = false
var dialog_was_shown: bool = false   # новое: флаг, что диалог уже прошёл


func _ready():
	add_to_group("dialog_triggers")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	$HintLabel.visible = false


func set_chain(c: DialogChain):
	chain = c


func _on_body_entered(body):
	if body.name == "Player":
		player_in_range = true
		dialog_was_shown = false   # сбрасываем флаг при входе
		$HintLabel.visible = true


func _on_body_exited(body):
	if body.name == "Player":
		player_in_range = false
		$HintLabel.visible = false


func _input(event):
	if not player_in_range:
		return
	if dialog_was_shown:
		return   # диалог уже прошёл, не запускаем снова
	
	if event.is_action_pressed("interact"):
		if chain:
			var sys = get_tree().get_first_node_in_group("dialog_system")
			if sys and not sys.is_dialog_active():
				sys.start_dialog(chain)
				# Подключаемся к сигналу завершения диалога
				if not sys.is_connected("dialog_ended", _on_dialog_ended):
					sys.dialog_ended.connect(_on_dialog_ended)


func _on_dialog_ended():
	dialog_was_shown = true
	$HintLabel.visible = false
	print("Диалог завершён, триггер заблокирован до следующего входа")
