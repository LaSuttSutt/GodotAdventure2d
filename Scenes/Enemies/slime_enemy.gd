extends CharacterBody2D

@export var speed: float = 30
@export var acceleration: float = 5
@export var HP: int = 2
var target: Node2D

func _physics_process(_delta: float) -> void:
	if HP <= 0:
		return
	
	chase_target()
	animate_enemy()
	move_and_slide()

func _on_player_detect_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		target = body

func chase_target() -> void:
	if target:
		var distance_to_player: Vector2
		distance_to_player = target.global_position - global_position
		
		var direction_normal: Vector2 = distance_to_player.normalized()
		velocity = velocity.move_toward(direction_normal * speed, acceleration)

func animate_enemy() -> void:
	var normal_velocity = velocity.normalized()
	if normal_velocity.x > 0.707:
		$AnimatedSprite2D.play("move_right")
	elif normal_velocity.x < -0.707:
		$AnimatedSprite2D.play("move_left")
	elif normal_velocity.y > 0.707:
		$AnimatedSprite2D.play("move_down")
	elif normal_velocity.y < -0.707:
		$AnimatedSprite2D.play("move_up")
		
func take_damage() -> void:
	$DamageSFX.play()
	modulate = Color(10, 0, 0)
	await get_tree().create_timer(0.2).timeout
	modulate = Color(1, 1, 1)
	
	HP -= 1
	if HP <= 0:
		die()

func die() -> void:
	$AnimatedSprite2D.visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	$GPUParticles2D.emitting = true
	
	await get_tree().create_timer(1).timeout
	
	queue_free()
