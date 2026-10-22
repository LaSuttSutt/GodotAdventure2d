extends StaticBody2D

var can_interact: bool = false
var dialogue_index: int = 0
@export var dialogue_lines: Array[String] = ["Hi!", "How are you?", "Bye!"]

func _process(_delta: float) -> void:
	if can_interact and Input.is_action_just_pressed("interact"):
		if dialogue_index < dialogue_lines.size():
			$CanvasLayer.visible = true
			get_tree().paused = true
			$CanvasLayer/DialogueLabel.text = dialogue_lines[dialogue_index]
			dialogue_index += 1
		else:
			$CanvasLayer.visible = false
			get_tree().paused = false
			dialogue_index = 0
