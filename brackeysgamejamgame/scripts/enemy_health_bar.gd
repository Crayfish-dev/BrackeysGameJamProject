extends TextureProgressBar

@export var enemy: Enemy
@onready var bar: TextureProgressBar = $"."

func _process(delta: float) -> void:
	if enemy:
		bar.value = enemy.hp
	else:
		return
