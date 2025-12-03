extends Node2D

@export var current_direction: Vector2 = Vector2.RIGHT
@export var current_strength: float = 250.0 #250 Corriente suave, 350 corriente media, 500 corriente fuerte

var bodies_in_area: Array = []

func _ready():
	current_direction = current_direction.normalized()

func _physics_process(delta):
	for body in bodies_in_area:
		if body.is_in_group("Player"):
			body.external_force += current_direction * current_strength * delta
			

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body not in bodies_in_area:
		bodies_in_area.append(body)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.external_force = Vector2.ZERO
	bodies_in_area.erase(body)
