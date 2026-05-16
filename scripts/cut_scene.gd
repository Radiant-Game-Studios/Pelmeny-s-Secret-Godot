extends CanvasLayer

@onready var video_player: VideoStreamPlayer = $VideoStreamPlayer

var next_map: String = ""
var video_file: String = ""


func setup(video: String, map_name: String):
	video_file = video
	next_map = map_name


func _ready():
	# Растягиваем на весь экран
	video_player.anchor_left = 0
	video_player.anchor_top = 0
	video_player.anchor_right = 1
	video_player.anchor_bottom = 1
	video_player.offset_left = 0
	video_player.offset_top = 0
	video_player.offset_right = 0
	video_player.offset_bottom = 0
	video_player.expand = true
	
	AudioManager.stop_music()
	
	if video_file != "":
		var video_path = MapManager.data_path().path_join("CutScenes").path_join(video_file)
		
		if FileAccess.file_exists(video_path):
			var stream = VideoStreamTheora.new()
			stream.file = video_path
			video_player.stream = stream
			video_player.play()
			video_player.finished.connect(_on_video_finished)
		else:
			_on_video_finished()
	else:
		_on_video_finished()


func _on_video_finished():
	SceneManager.pending_map = next_map
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _input(event):
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("interact"):
		if video_player and video_player.is_playing():
			video_player.stop()
		_on_video_finished()
