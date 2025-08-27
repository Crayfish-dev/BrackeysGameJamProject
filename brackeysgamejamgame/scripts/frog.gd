extends Enemy

@onready var pivot: Node2D = $Pivot
@onready var player: PlayerController = $"../Player"
@onready var shape: Area2D = $Pivot/DamageShape
@onready var detector: Area2D = $Detector
@onready var bite: AnimatedSprite2D = $Pivot/Bite

func _process(delta: float) -> void:
	pivot.look_at(player.position)




func _on_damage_shape_body_entered(body: PlayerController) -> void:
	body.take_damage(damage)
	var knockback_direction = (body.global_position - global_position).normalized()
	var knockback_strength = 250
	var knockback_velocity = knockback_direction * knockback_strength
	body.apply_knockback(knockback_velocity)

	var player_knockback_strength = 400
	var player_knockback = -knockback_direction * player_knockback_strength
	velocity += player_knockback


func _on_detector_body_entered(body: PlayerController) -> void:
	await get_tree().create_timer(0.3).timeout
	shape.monitoring = true
	bite.visible = true
	bite.play("bite")
	await get_tree().create_timer(0.1).timeout
	shape.monitoring = false
	


func _on_bite_animation_finished() -> void:
	bite.visible = false
