extends CharacterBody2D
class_name Enemy

@export var damage: int = 10.0
@export var sprite: Node2D
@export var hp: int = 100.0
var immune: bool = false
var deceleration: float = 10.0  # Lower = slower stop, tweak as needed

func _physics_process(delta: float) -> void:
	if hp <= 0:
		await get_tree().create_timer(0.2).timeout
		queue_free()
	
	# Just apply deceleration to stop smoothly
	velocity = lerp(velocity, Vector2.ZERO, delta * deceleration)

	move_and_slide()

func take_damage(dm: int):
	if immune:
		return
	hp -= dm
	immune = true
	sprite.modulate = Color(0, 0, 0)
	await get_tree().create_timer(0.5).timeout
	immune = false
	sprite.modulate = Color(1, 1, 1)

func apply_knockback(velocity: Vector2) -> void:
	self.velocity = velocity
