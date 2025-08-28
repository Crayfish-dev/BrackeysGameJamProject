extends Enemy

@onready var pivot: Node2D = $Pivot
@onready var player: PlayerController = $"../Player"
@onready var shape: Area2D = $Pivot/DamageShape
@onready var detector: Area2D = $Detector
@onready var arrow: AnimatedSprite2D = $Pivot/arrow

# Movement behavior
var move_speed: float = 60.0
var min_distance: float = 60.0  # too close, move away
var max_distance: float = 160.0  # too far, move closer

func _physics_process(delta: float) -> void:
	
	if hp <= 0 or hp == 0:
		queue_free()
	
	if is_chasing and player and not immune:
		var distance_to_player = global_position.distance_to(player.global_position)
		var direction = (player.global_position - global_position).normalized()

		if distance_to_player < min_distance:
			# Too close — back away
			velocity = -direction * move_speed
		elif distance_to_player > max_distance:
			# Too far — move closer
			velocity = direction * move_speed
		else:
			# Ideal range — don't steer
			pass
	else:
		# Don't steer; immune or not chasing — retain existing velocity
		pass

	move_and_slide()

func _process(delta: float) -> void:
	if player:
		pivot.look_at(player.position)

func _on_damage_shape_body_entered(body: PlayerController) -> void:
	body.take_damage(damage)
	var knockback_direction = (body.global_position - global_position).normalized()
	var knockback_strength = 1000
	var knockback_velocity = knockback_direction * knockback_strength
	body.apply_knockback(knockback_velocity)

	# Enemy gets pushed slightly (if needed)
	var player_knockback_strength = 0
	var player_knockback = -knockback_direction * player_knockback_strength
	velocity += player_knockback

func _on_detector_body_entered(body: PlayerController) -> void:
	await get_tree().create_timer(0.5).timeout
	shape.monitoring = true
	arrow.visible = true
	arrow.play("shoot")
	await get_tree().create_timer(0.1).timeout
	shape.monitoring = false

func _on_arrow_animation_finished() -> void:
	arrow.visible = false

func _on_chasing_area_body_entered(body: Node2D) -> void:
	if body == player:
		is_chasing = true

func _on_chasing_area_body_exited(body: Node2D) -> void:
	if body == player:
		is_chasing = false
