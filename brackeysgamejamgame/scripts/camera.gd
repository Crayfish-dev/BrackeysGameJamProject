extends Camera2D

@export var player: PlayerController 
func _process(delta: float) -> void:
	if player:
		position = player.position
