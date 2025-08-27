extends Camera2D

@export var player: PlayerController 
@onready var blood_bar: TextureProgressBar = $CanvasLayer/BloodBar
@onready var health_bar: TextureProgressBar = $CanvasLayer/HealthBar



func _process(delta: float) -> void:
	if player:
		position = player.position
		health_bar.value = player.hp
		blood_bar.value = player.blood
