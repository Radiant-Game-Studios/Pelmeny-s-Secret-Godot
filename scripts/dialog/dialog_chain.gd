class_name DialogChain
extends Resource

@export var dialog_id: String = ""
@export var steps: Array[Resource] = []   # массив DialogTextStep или DialogChoiceStep
