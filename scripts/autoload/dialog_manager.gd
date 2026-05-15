extends Node

var dialog_system: Node = null


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS


func register_dialog_system(system: Node):
	dialog_system = system


func start_dialog(chain):
	if dialog_system:
		dialog_system.start_dialog(chain)


func is_dialog_active() -> bool:
	if dialog_system:
		return dialog_system.is_dialog_active()
	return false
