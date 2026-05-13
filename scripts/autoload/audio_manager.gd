extends Node

# Аудиоплееры
var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

# Громкость (0.0 - 1.0)
var music_volume: float = 0.5
var sfx_volume: float = 1.0

# Кэш загруженных звуков
var sfx_cache: Dictionary = {}


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Создаём плеер для музыки
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"  # шина Music (создадим ниже)
	add_child(music_player)
	
	# Создаём плеер для звуков
	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "SFX"      # шина SFX
	add_child(sfx_player)


func play_music(stream: AudioStream, fade_in: float = 0.5) -> void:
	if music_player.playing:
		# Плавная смена трека (fade out старый, fade in новый)
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", -80, 0.3)
		tween.tween_callback(func():
			music_player.stream = stream
			music_player.play()
			var tween2 = create_tween()
			tween2.tween_property(music_player, "volume_db", linear_to_db(music_volume), fade_in)
		)
	else:
		music_player.stream = stream
		music_player.volume_db = linear_to_db(music_volume)
		music_player.play()


func stop_music(fade_out: float = 0.5) -> void:
	var tween = create_tween()
	tween.tween_property(music_player, "volume_db", -80, fade_out)
	tween.tween_callback(func():
		music_player.stop()
	)


func play_sfx(stream: AudioStream, volume: float = 1.0) -> void:
	# Для нескольких звуков одновременно — создаём временный плеер
	var player = AudioStreamPlayer.new()
	player.bus = "SFX"
	player.stream = stream
	player.volume_db = linear_to_db(sfx_volume * volume)
	player.finished.connect(player.queue_free)
	add_child(player)
	player.play()


func play_sfx_path(path: String, volume: float = 1.0) -> void:
	# Загрузка из файла с кэшированием
	if not sfx_cache.has(path):
		sfx_cache[path] = load(path)
	play_sfx(sfx_cache[path], volume)


func set_music_volume(vol: float) -> void:
	music_volume = clamp(vol, 0.0, 1.0)
	music_player.volume_db = linear_to_db(music_volume)


func set_sfx_volume(vol: float) -> void:
	sfx_volume = clamp(vol, 0.0, 1.0)
