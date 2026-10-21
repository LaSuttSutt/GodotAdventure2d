extends StaticBody2D

var can_interact: bool = false

func _process(_delta: float) -> void:
	if can_interact and Input.is_action_just_pressed("interact"):
		$CanvasLayer.visible = !$CanvasLayer.visible
		get_tree().paused = $CanvasLayer.visible
