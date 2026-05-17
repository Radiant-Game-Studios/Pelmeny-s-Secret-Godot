class_name AnimationGenerator
extends RefCounted

static func generate_enemy_frames(size: Vector2, color: Color, eye_color: Color = Color.WHITE) -> SpriteFrames:
	var frames = SpriteFrames.new()
	
	# Idle (2 кадра)
	frames.add_animation("idle")
	for i in range(2):
		var img = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
		img.fill(color)
		# Глаза
		var eye_y = size.y * 0.3
		img.fill_rect(Rect2i(size.x*0.25, eye_y, 4, 4), eye_color)
		img.fill_rect(Rect2i(size.x*0.75-4, eye_y, 4, 4), eye_color)
		# Лёгкое смещение для "оживления"
		if i == 1:
			img.fill_rect(Rect2i(size.x*0.25+1, eye_y, 4, 4), eye_color)
		var tex = ImageTexture.create_from_image(img)
		frames.add_frame("idle", tex)
	
	# Run (3 кадра)
	frames.add_animation("run")
	for i in range(3):
		var img = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
		img.fill(color)
		# Глаза смещаются вперёд
		var offset_x = i * 2
		img.fill_rect(Rect2i(size.x*0.25 + offset_x, size.y*0.3, 4, 4), eye_color)
		img.fill_rect(Rect2i(size.x*0.75-4 + offset_x, size.y*0.3, 4, 4), eye_color)
		# "Ноги" – полоски внизу
		img.fill_rect(Rect2i(4, size.y-6, 8, 6), color.darkened(0.3))
		img.fill_rect(Rect2i(size.x-12, size.y-6, 8, 6), color.darkened(0.3))
		var tex = ImageTexture.create_from_image(img)
		frames.add_frame("run", tex)
	
	# Attack (2 кадра)
	frames.add_animation("attack")
	for i in range(2):
		var img = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
		img.fill(color)
		# Глаза
		img.fill_rect(Rect2i(size.x*0.25, size.y*0.3, 4, 4), eye_color)
		img.fill_rect(Rect2i(size.x*0.75-4, size.y*0.3, 4, 4), eye_color)
		# "Оружие" – красный квадрат, выдвигается вперёд
		var weapon_x = size.x + i*6
		img.fill_rect(Rect2i(weapon_x, size.y*0.4, 8, 8), Color.RED)
		var tex = ImageTexture.create_from_image(img)
		frames.add_frame("attack", tex)
	
	frames.set_animation_speed("idle", 5.0)
	frames.set_animation_speed("run", 8.0)
	frames.set_animation_speed("attack", 10.0)
	return frames

# Для ГГ аналогично, но с другим цветом
static func generate_player_attack_frames(existing_frames: SpriteFrames) -> void:
	if not existing_frames.has_animation("idle"):
		return
	
	var idle_texture = existing_frames.get_frame_texture("idle", 0)
	var idle_image = idle_texture.get_image()
	var size = idle_image.get_size()
	
	existing_frames.add_animation("attack")
	
	for i in range(2):
		# Создаём новое изображение БОЛЬШЕ по ширине (чтобы влез меч)
		var new_width = size.x + 16
		var new_img = Image.create(new_width, size.y, false, Image.FORMAT_RGBA8)
		
		# Копируем персонажа (слева)
		new_img.blit_rect(idle_image, Rect2i(0, 0, size.x, size.y), Vector2i(0, 0))
		
		# Рисуем "меч" справа от персонажа
		var sword_x = size.x + i * 8  # больше сдвиг
		var sword_y = size.y * 0.4
		new_img.fill_rect(Rect2i(sword_x, sword_y, 16, 6), Color.YELLOW)  # длиннее и толще
		new_img.fill_rect(Rect2i(sword_x + 4, sword_y - 3, 6, 12), Color.BROWN)  # больше рукоять
		
		var tex = ImageTexture.create_from_image(new_img)
		existing_frames.add_frame("attack", tex)
	
	existing_frames.set_animation_speed("attack", 6.0)
