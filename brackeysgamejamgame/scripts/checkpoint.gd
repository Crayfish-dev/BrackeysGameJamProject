extends StaticBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var claimed: bool = false

func _on_detector_body_entered(body: PlayerController) -> void:
	GameManager.set_checkpoint(position)
	claimed = true

func _process(delta: float) -> void:
	if GameManager.last_checkpoint_position == position:
		claimed = true
	else:
		claimed = false
	
	if claimed:
		sprite.play("opened")
	else:
		sprite.play("closed")
