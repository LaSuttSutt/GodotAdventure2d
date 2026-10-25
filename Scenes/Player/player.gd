extends CharacterBody2D
class_name Player

@export var move_speed: float = 100
@export var acceleration: float = 10
@export var push_strength: float = 10

var is_attacking: bool = false
var can_interact: bool = false

#region Godot events -----------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if SceneManager.player_spawn_position != Vector2(0, 0):
		position = SceneManager.player_spawn_position
	update_treasure_label()
	update_hp_bar()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if SceneManager.player_hp <= 0:
		return
	
	if not is_attacking:
		move_player()
		
	push_box()
	
	if Input.is_action_just_pressed("interact") and not can_interact:
		attack()
	
	update_treasure_label()
	move_and_slide()

#endregion

#region Signals ----------------------------------------------------------------

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("interactable"):
		body.can_interact = true
		can_interact = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("interactable"):
		body.can_interact = false
		can_interact = false

func _on_hitbox_area_2d_body_entered(body: Node2D) -> void:
	SceneManager.player_hp -= 1
	update_hp_bar()
	if SceneManager.player_hp <= 0:
		die()
	
	var distance_to_enemy: Vector2 = global_position - body.global_position
	var knockback_direction = distance_to_enemy.normalized()
	var knockback_strength: float = 200
	velocity += knockback_direction * knockback_strength
	
	$DamageSFX.play()
	
	modulate = Color(50, 50, 50)
	await get_tree().create_timer(0.2).timeout
	modulate = Color(1, 1, 1)

func _on_sword_area_2d_body_entered(body: Node2D) -> void:
	var distance_to_enemy: Vector2 = body.global_position - global_position
	var knockback_direction = distance_to_enemy.normalized()
	var knockback_strength: float = 150
	body.velocity += knockback_direction * knockback_strength
	body.take_damage()

func _on_attack_duration_timer_timeout() -> void:
	is_attacking = false
	$Sword.visible = false
	%SwordArea2D.monitoring = false
	var animation: String = $AnimatedSprite2D.animation
	if animation == "attack_right":
		$AnimatedSprite2D.play("move_right")
	elif animation == "attack_left":
		$AnimatedSprite2D.play("move_left")
	elif animation == "attack_up":
		$AnimatedSprite2D.play("move_up")
	elif animation == "attack_down":
		$AnimatedSprite2D.play("move_down")

func _on_death_timer_timeout() -> void:
	SceneManager.player_hp = 3
	get_tree().call_deferred("reload_current_scene")

#endregion

#region Functions --------------------------------------------------------------

func move_player() -> void:
	var move_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = velocity.move_toward(move_vector * move_speed, acceleration)
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
	$AnimatedSprite2D.play("death")
	if $DeathTimer.is_stopped():
		$DeathTimer.start()

func update_hp_bar() -> void:
	if SceneManager.player_hp == 3:
		%HPBar.play("3_hp")
	elif SceneManager.player_hp == 2:
		%HPBar.play("2_hp")
	elif SceneManager.player_hp == 1:
		%HPBar.play("1_hp")
	else:
		%HPBar.play("0_hp")

func attack() -> void:
	if not $AttackDurationTimer.is_stopped():
		return
	
	$AttackSFX.play()
	is_attacking = true
	velocity = Vector2(0, 0)
	$Sword.visible = true
	%SwordArea2D.monitoring = true
	$AttackDurationTimer.start()
	var animation: String = $AnimatedSprite2D.animation
	if animation == "move_right":
		$AnimatedSprite2D.play("attack_right")
		$AnimationPlayer.play("attack_right")
	elif animation == "move_left":
		$AnimatedSprite2D.play("attack_left")
		$AnimationPlayer.play("attack_left")
	elif animation == "move_up":
		$AnimatedSprite2D.play("attack_up")
		$AnimationPlayer.play("attack_up")
	elif animation == "move_down":
		$AnimatedSprite2D.play("attack_down")
		$AnimationPlayer.play("attack_down")

#endregion
