extends CharacterBody2D
class_name Player

@export var move_speed: float = 100
@export var push_strength: float = 10

#region Godot events -----------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if SceneManager.player_spawn_position != Vector2(0, 0):
		position = SceneManager.player_spawn_position
	update_treasure_label()
	update_hp_bar()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	move_player()
	push_box()
	update_treasure_label()
	move_and_slide()

#endregion

#region Signals ----------------------------------------------------------------

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("interactable"):
		body.can_interact = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("interactable"):
		body.can_interact = false

func _on_hitbox_area_2d_body_entered(_body: Node2D) -> void:
	SceneManager.player_hp -= 1
	update_hp_bar()
	if SceneManager.player_hp <= 0:
		die()
	
#endregion

#region Functions --------------------------------------------------------------

func move_player() -> void:
	var move_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = move_vector * move_speed
	if velocity.length() > 0:
		if abs(velocity.x) >= abs(velocity.y):
			if velocity.x > 0:
				$AnimatedSprite2D.play("move_right")
				$InteractArea2D.position = Vector2(5, 2)
			else:
				$AnimatedSprite2D.play("move_left")
				$InteractArea2D.position = Vector2(-5, 2)
		else:
			if velocity.y > 0:
				$AnimatedSprite2D.play("move_down")
				$InteractArea2D.position = Vector2(0, 8)
			else:
				$AnimatedSprite2D.play("move_up")
				$InteractArea2D.position = Vector2(0, -4)
	else:
		$AnimatedSprite2D.stop()

func push_box() -> void:
	var collision: KinematicCollision2D = get_last_slide_collision()
	if collision:
		var collider_node = collision.get_collider()
		if collider_node.is_in_group("pushable"):
			var collision_normal: Vector2 = collision.get_normal()
			collider_node.apply_central_force(-collision_normal * push_strength)

func update_treasure_label() -> void:
	%TreasureLabel.text = str(SceneManager.opened_chests.size())
	
func die() -> void:
	SceneManager.player_hp = 3
	get_tree().call_deferred("reload_current_scene")

func update_hp_bar() -> void:
	if SceneManager.player_hp == 3:
		%HPBar.play("3_hp")
	elif SceneManager.player_hp == 2:
		%HPBar.play("2_hp")
	elif SceneManager.player_hp == 1:
		%HPBar.play("1_hp")
	else:
		%HPBar.play("0_hp")

#endregion
