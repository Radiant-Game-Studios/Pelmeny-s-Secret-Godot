extends Control

@onready var video_player: VideoStreamPlayer = $VideoStreamPlayer
#@onready var skip_label: Label = $Label

var next_map: String = ""
var video_file: String = ""


func setup(video: String, map_name: String):
	print("Кат-сцена setup: видео=", video, " карта=", map_name)
	video_file = video
	next_map = map_name


func _ready():
	print("Кат-сцена _ready начат")
	
	# Останавливаем музыку меню
	if AudioManager:
		AudioManager.stop_music()
	
	if video_file != "":
		var video_path = MapManager.data_path().path_join("CutScenes").path_join(video_file)
		print("Ищем видео: ", video_path)
		
		if FileAccess.file_exists(video_path):
			print("Видео найдено, запускаем")
			var stream = VideoStreamTheora.new()
			stream.file = video_path
			video_player.stream = stream
			video_player.play()
			video_player.finished.connect(_on_video_finished)
		else:
			print("Видео НЕ найдено: ", video_path)
			# Не переходим сразу — даём игроку увидеть сообщение
			#skip_label.text = "Видео не найдено: " + video_file + "\nНажмите Enter для продолжения"
			#skip_label.visible = true
	else:
		print("video_file пуст, переходим к карте")
		_on_video_finished()


func _on_video_finished():
	print("Кат-сцена завершена, загружаем карту: ", next_map)
	SceneManager.pending_map = next_map
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _input(event):
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("interact"):
		print("Нажата клавиша пропуска")
		if video_player and video_player.playing:
			video_player.stop()
		_on_video_finished()
