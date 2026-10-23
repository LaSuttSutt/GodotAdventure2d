extends StaticBody2D

@export var chest_name: String = "Chest"
var can_interact: bool = false
var is_open: bool = false

func _ready() -> void:
	is_open = SceneManager.opened_chests.has(chest_name)
	if is_open:
		$AnimatedSprite2D.play("open")

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and can_interact and not is_open:
		open_chest()

func open_chest() -> void:
	$AnimatedSprite2D.play("open")
	is_open = true
	$Sprite2D.visible = true
	$Timer.start()
	$AudioStreamPlayer2D.play()
	SceneManager.opened_chests.append(chest_name)


func _on_timer_timeout() -> void:
	$Sprite2D.visible = false
