extends CanvasLayer

signal dialog_started
signal dialog_ended

@onready var panel = $Panel
@onready var portrait = $Panel/Portrait
@onready var name_label = $Panel/Portrait/NameLabel
@onready var text_label = $Panel/TextLabel
@onready var choices_container = $Panel/TextLabel/ChoicesContainer
#@onready var continue_hint = $ContinueHint

var current_chain: DialogChain
var current_step_index: int = 0
var is_active: bool = false
var in_choice: bool = false
var choice_step: DialogChoiceStep = null

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("dialog_system")

func _input(event):
	if not is_active:
		return
	# Проверка мобильной кнопки E
	var mobile = get_tree().get_first_node_in_group("mobile_controls")
	if mobile and mobile.visible and mobile.interact_pressed:
		if in_choice:
			return
		advance()
		return
	if event.is_action_pressed("interact"):
		if in_choice:
			return  # выбор только кликом
		advance()

func start_dialog(chain: DialogChain):
	if is_active:
		return
	current_chain = chain
	current_step_index = 0
	is_active = true
	visible = true
	dialog_started.emit()
	show_step()

func show_step():
	if current_step_index >= current_chain.steps.size():
		print("Диалог завершён — шагов больше нет")
		end_dialog()
		return
	
	var step = current_chain.steps[current_step_index]
	var script_path = ""
	if step.get_script():
		script_path = step.get_script().resource_path
	
	print("Показываю шаг ", current_step_index, " скрипт: ", script_path)
	
	if script_path.ends_with("dialog_text_step.gd"):
		var rep = step
		in_choice = false
		choices_container.visible = false
		text_label.visible = true
		portrait.texture = rep.character.portrait if rep.character else null
		name_label.text = rep.character.character_name if rep.character else ""
		text_label.text = LocalizationManager.get_replica(rep.replica_index)
		
	elif script_path.ends_with("dialog_choice_step.gd"):
		print("  Это шаг выбора!")
		in_choice = true
		choice_step = step
		text_label.text = ""
		text_label.visible = true
		choices_container.visible = true
		
		for child in choices_container.get_children():
			child.queue_free()
		
		for i in range(choice_step.choices.size()):
			var btn = Button.new()
			btn.text = LocalizationManager.get_replica(choice_step.choices[i])
			btn.pressed.connect(_on_choice_selected.bind(i))
			choices_container.add_child(btn)
	else:
		print("Пропускаю неизвестный шаг")
		current_step_index += 1
		show_step()


func _on_choice_selected(index: int):
	if not in_choice:
		return
	
	print("Выбран вариант ", index)
	in_choice = false
	choices_container.visible = false
	text_label.visible = true
	
	var rep_index = choice_step.reply_indices[index]
	var chara = choice_step.reply_character
	portrait.texture = chara.portrait if chara else null
	name_label.text = chara.character_name if chara else ""
	text_label.text = LocalizationManager.get_replica(rep_index)
	
	# Переходим к следующему шагу сразу после выбора
	current_step_index += 1
	choice_step = null


func advance():
	print("advance: current_step_index=", current_step_index, " in_choice=", in_choice)
	if in_choice:
		print("  Всё ещё в выборе — ждём клика по кнопке")
		return
	
	current_step_index += 1
	show_step()

func end_dialog():
	is_active = false
	visible = false
	dialog_ended.emit()
	current_chain = null

func is_dialog_active() -> bool:
	return is_active
