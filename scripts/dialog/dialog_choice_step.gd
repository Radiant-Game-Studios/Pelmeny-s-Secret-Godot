class_name DialogChoiceStep
extends Resource

const DialogCharacter = preload("res://scripts/dialog/dialog_character.gd")

@export var choices: Array[int] = []       # индексы реплик для вариантов
@export var reply_indices: Array[int] = [] # индексы реплик после выбора (по одной на каждый вариант)
@export var reply_character: DialogCharacter  # персонаж, который произносит ответ
# Дальнейшие шаги можно задать через массив steps, но пока упростим
