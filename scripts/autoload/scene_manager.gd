extends Node

var current_scene: Node = null
var pending_map: String = "test.map"

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS


func go_to_game(map_file: String = "test.map"):
	pending_map = map_file
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func go_to_main_menu():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func quit_game():
	get_tree().quit()
