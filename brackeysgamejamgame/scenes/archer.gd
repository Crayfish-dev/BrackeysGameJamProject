extends Enemy

@onready var pivot: Node2D = $Pivot
@onready var player: PlayerController = $"../Player"
@onready var shape: Area2D = $Pivot/DamageShape
@onready var detector: Area2D = $Detector
@onready var arrow: AnimatedSprite2D = $Pivot/arrow


func _process(delta: float) -> void:
	
	
	pivot.look_at(player.position)
	



func _on_damage_shape_body_entered(body: PlayerController) -> void:
	body.take_damage(damage)
	var knockback_direction = (body.global_position - global_position).normalized()
	var knockback_strength = 1000
	var knockback_velocity = knockback_direction * knockback_strength
	body.apply_knockback(knockback_velocity)

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
