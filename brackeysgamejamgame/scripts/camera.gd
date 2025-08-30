extends Camera2D

@export var player: PlayerController 
@onready var blood_bar: TextureProgressBar = $CanvasLayer/BloodBar
@onready var health_bar: TextureProgressBar = $CanvasLayer/HealthBar
@onready var bat_bar: TextureProgressBar = $CanvasLayer/BatBar



func _process(delta: float) -> void:
	if player:
		position = player.position
		health_bar.value = player.hp
		blood_bar.value = player.blood
		bat_bar.value = (player.bat_time / player.max_bat_time) * 100
