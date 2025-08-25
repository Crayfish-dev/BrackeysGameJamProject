extends CharacterBody2D
class_name PlayerController

const max_speed: int = 90
const acceleration: int = 10
const friction: int = 16
var dash_velocity = max_speed * 5

func _physics_process(delta: float) -> void:
	var can_dash = true
	var input = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()

	var lerp_weight = delta * (acceleration if input else friction)
	velocity = lerp(velocity, input * max_speed, lerp_weight)
	var direction = 0
	var ydirection = 0
	if Input.is_action_pressed("right"):
		direction = 1
	elif Input.is_action_pressed("left"):
		direction = -1
	if Input.is_action_pressed("up"):
		ydirection = -1
	elif Input.is_action_pressed("down"):
		ydirection = 1
	
	


	if Input.is_action_just_pressed("dash") and can_dash == true:
		velocity.y = dash_velocity * ydirection
		velocity.x = dash_velocity * direction
		can_dash = false
		await get_tree().create_timer(10).timeout
		can_dash = true

	move_and_slide()
