extends Enemy

@onready var pivot: Node2D = $Pivot
@onready var shape: Area2D = $Pivot/DamageShape
@onready var detector: Area2D = $Detector
@onready var bite: AnimatedSprite2D = $Pivot/Bite
@onready var emotion: AnimatedSprite2D = $EmotionPoint

# Chasing behavior
var move_speed: float = 70.0
var target_position: Vector2
var target_reached_threshold: float = 15.0
var reposition_interval: float = 2
var reposition_timer: float = 0.0

# Knockback velocity and friction
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_friction: float = 10000000000000000000.0  # Adjust this to control how fast knockback slows

func _physics_process(delta: float) -> void:
	if hp <= 0 or hp == 0:
		sprite.play("die")
		await get_tree().create_timer(1).timeout
		queue_free()
	
	var move_velocity = Vector2.ZERO

	if is_chasing and player:
		reposition_timer -= delta

		if reposition_timer <= 0.0 or global_position.distance_to(target_position) < target_reached_threshold:
			target_position = get_random_position_near_player()
			reposition_timer = reposition_interval

		var direction = (target_position - global_position).normalized()
		move_velocity = direction * move_speed
	else:
		move_velocity = Vector2.ZERO

	# Apply knockback velocity with friction
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_friction * delta)

	velocity = move_velocity + knockback_velocity
	move_and_slide()

	# Sprite Animation and Flipping
	if sprite:
		# Flip horizontally based on X movement direction
		if abs(velocity.x) > 5:
			sprite.flip_h = velocity.x > 0  

		if velocity.length() < 10:
			if abs(velocity.y) > abs(velocity.x):
				if velocity.y < 0:
					sprite.play("back_idle")
				else:
					sprite.play("front_idle")
			else:
				sprite.play("front_idle")
		else:
			if abs(velocity.y) > abs(velocity.x):
				if velocity.y < 0:
					sprite.play("back_walk")
				else:
					sprite.play("front_walk")
			else:
				sprite.play("front_walk")

func _process(delta: float) -> void:
	if player:
		pivot.look_at(player.position)

func get_random_position_near_player(radius: float = 100.0) -> Vector2:
	var angle = randf() * TAU
	var offset = Vector2(cos(angle), sin(angle)) * randf_range(30, radius)
	return player.global_position + offset

func _on_damage_shape_body_entered(body: PlayerController) -> void:
	if body.bat:
		return
	body.take_damage(damage)
	
	# Knockback applied to the player
	var knockback_direction = (body.global_position - global_position).normalized()
	var knockback_strength = 250
	var knockback_velocity_player = knockback_direction * knockback_strength
	body.apply_knockback(knockback_velocity_player)

	var player_knockback_strength = 400
	var player_knockback = -knockback_direction * player_knockback_strength
	knockback_velocity += player_knockback 

func _on_detector_body_entered(body: PlayerController) -> void:
	if body.bat:
		return
	await get_tree().create_timer(0.3).timeout
	shape.monitoring = true
	bite.visible = true
	bite.play("bite")
	await get_tree().create_timer(0.1).timeout
	shape.monitoring = false

func _on_bite_animation_finished() -> void:
	bite.visible = false

func _on_chasing_area_body_entered(body: PlayerController) -> void:
	if body.bat:
		return
	emotion.play("exclamation")
	is_chasing = true
	target_position = get_random_position_near_player()
	reposition_timer = 0.0

func _on_chasing_area_body_exited(body: PlayerController) -> void:
	if body.bat:
		return
	emotion.play("wonder")
	is_chasing = false
