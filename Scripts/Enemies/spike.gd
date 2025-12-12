extends Area2D

var velocity: Vector2 = Vector2.ZERO
@export var damage: float = 0.5
@export var knockback: float = 50
var lifetime: float = 10.0 
var shooter: Node2D = null  
const SPYKE_SPLASH = preload("uid://cxfaf6o4fets8")

func set_direction(dir: Vector2, spd: float) -> void:
	velocity = dir * spd
	rotation = dir.angle() - PI/2

func set_shooter(shooter_node: Node2D) -> void:
	shooter = shooter_node

func _physics_process(delta: float) -> void:
	global_position += velocity * delta
	lifetime -= delta
	if lifetime <= 0:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("WorldCollider"):
		spyke_splash()
		queue_free()
	#if body.is_in_group("Player"):
	#	body.take_damage(damage, global_position, knockback)
	#queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		area.get_parent().take_damage(damage, global_position, knockback)
		spyke_splash()
		queue_free()
	elif area.is_in_group("WorldCollider"):
		spyke_splash()
		queue_free()

func spyke_splash() -> void:
	var spykeSplash = SPYKE_SPLASH.instantiate()
	spykeSplash.global_position = global_position
	get_parent().add_child(spykeSplash)
