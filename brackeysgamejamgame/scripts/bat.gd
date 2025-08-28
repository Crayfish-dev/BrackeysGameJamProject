extends Enemy

@onready var player: PlayerController = $"../Player"
@onready var chasing_area: Area2D = $ChasingArea



# Chasing behavior
var move_speed: float = 100.0
var target_position: Vector2
var target_reached_threshold: float = 15.0
var reposition_interval: float = 0.3
var reposition_timer: float = 0.0

# Knockback velocity and friction
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_friction: float = 10000000000000000000.0  # Adjust this to control how fast knockback slows

func _physics_process(delta: float) -> void:
	
	if hp <= 0 or hp == 0:
		queue_free()
	
	var move_velocity = Vector2.ZERO  # Declare once here

	if is_chasing and player:
		reposition_timer -= delta

		if reposition_timer <= 0.0 or global_position.distance_to(target_position) < target_reached_threshold:
			target_position = get_random_position_near_player()
			reposition_timer = reposition_interval

		var direction = (target_position - global_position).normalized()
		move_velocity = direction * move_speed
	else:
		move_velocity = Vector2.ZERO  # Just assign here

	# Apply friction to knockback velocity so it slows down smoothly
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_friction * delta)

	velocity = move_velocity + knockback_velocity
	move_and_slide()



func get_random_position_near_player(radius: float = 100.0) -> Vector2:
	var angle = randf() * TAU
	var offset = Vector2(cos(angle), sin(angle)) * randf_range(30, radius)
	return player.global_position + offset



func _on_chasing_area_body_entered(body: PlayerController) -> void:
	is_chasing = true
	target_position = get_random_position_near_player()
	reposition_timer = 0.0

func _on_chasing_area_body_exited(body: PlayerController) -> void:
	is_chasing = false


func _on_blood_area_body_entered(body: PlayerController) -> void:
	body.blood -= 5
