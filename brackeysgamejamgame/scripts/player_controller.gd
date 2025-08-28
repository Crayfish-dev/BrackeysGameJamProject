extends CharacterBody2D
class_name PlayerController

@onready var damage_box: Area2D = $DamageOrbitatingPoint/DamageBox
@onready var damage_point: Node2D = $DamageOrbitatingPoint
@onready var sprite: Sprite2D = $Sprite2D
@onready var bite: AnimatedSprite2D = $DamageOrbitatingPoint/Bite
@onready var collision: CollisionShape2D = $CollisionShape2D

const max_speed: int = 90
const acceleration: int = 10
const friction: int = 16
const dash_velocity := max_speed * 5
const ATTACK_BOOST_STRENGTH := 350  # Velocity boost when attacking
var can_parry: bool = true
var blood: int = 35
var can_dash: bool = true
var hp: int = 100
var immune: bool = false

func _ready() -> void:
	damage_box.monitoring = false
	_start_blood_drain()


func _physics_process(delta: float) -> void:
	if blood >= 15 and hp <= 100 and Input.is_action_pressed("heal"):
		velocity = Vector2.ZERO
		await get_tree().create_timer(0.1).timeout
		blood -= 1
		hp += 5
		return


	if hp <= 0:
		get_tree().reload_current_scene()

	var input = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()


	if blood > 100:
		blood = 100
	elif blood < 0:
		blood = 0
	elif blood == 0:
		hp = 0
	
	if Input.is_action_just_pressed("attack") and blood >= 10 and immune == false:
		attack(10)

	damage_point.look_at(get_global_mouse_position())
	
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

	if Input.is_action_just_pressed("dash") and can_dash:
		collision.disabled = true
		attack(1)
		velocity.y = dash_velocity * ydirection
		velocity.x = dash_velocity * direction
		can_dash = false
		await get_tree().create_timer(0.5).timeout
		collision.disabled = false
		await get_tree().create_timer(0.5).timeout
		can_dash = true

	move_and_slide()


func _on_damage_box_body_entered(body: Enemy) -> void:
	body.take_damage(10)
	print(body.hp)
	blood += 15
	var knockback_direction = (body.global_position - global_position).normalized()
	var knockback_strength = 250
	var knockback_velocity = knockback_direction * knockback_strength
	body.apply_knockback(knockback_velocity)

	var player_knockback_strength = 400
	var player_knockback = -knockback_direction * player_knockback_strength
	velocity += player_knockback


func _start_blood_drain() -> void:
	while true:
		await get_tree().create_timer(4).timeout
		blood = max(blood - 1, 0) 

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


func _on_bite_animation_finished() -> void:
	bite.visible = false

func attack(bl):
		blood -= bl
		damage_box.monitoring = true
		bite.visible = true
		bite.play("bite")
		var direction_to_mouse = (get_global_mouse_position() - global_position).normalized()
		velocity += direction_to_mouse * ATTACK_BOOST_STRENGTH
		await get_tree().create_timer(0.1).timeout
		damage_box.monitoring = false
