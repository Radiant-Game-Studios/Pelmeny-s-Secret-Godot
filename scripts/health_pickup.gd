extends Area2D

@export var heal_amount: float = 25.0

var player_nearby: bool = false


func _ready():
	# Подключаем сигналы
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	add_to_group("pickups")


func _on_body_entered(body):
	print("Body entered: ", body.name)
	if body.is_in_group("player"):
		player_nearby = true
		print("Игрок рядом с хилкой!")


func _on_body_exited(body):
	if body.is_in_group("player"):
		player_nearby = false
		print("Игрок отошёл от хилки")
