extends Area2D

var velocity: Vector2 = Vector2.ZERO
@export var damage: float = 0.5
@export var knockback: float = 50
var lifetime: float = 20.0 
var shooter: Node2D = null  

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

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
	if body == shooter:
		return
	if body.is_in_group("Player"):
		body.take_damage(damage, global_position, knockback)
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		area.get_parent().take_damage(damage, global_position, knockback)
		queue_free()
