extends CharacterBody2D

@export var damage: float = 0.5
@export var speed: float = 50
@export var direction: int = 1
@export var knockback: float = 100 #Efecto de echar para atras al jugador al golpearle

enum PatrolMode {HORIZONTAL, VERTICAL}
@export var patrol_mode: PatrolMode = PatrolMode.VERTICAL


		
func _physics_process(delta: float) -> void:
	#Movemos horizontalmente el enemigo
	#velocity.x = direction * speed
	#velocity.y = 0
	match patrol_mode:
		PatrolMode.HORIZONTAL:
			velocity.y = 0
			velocity.x = direction * speed
		PatrolMode.VERTICAL:
			velocity.x = 0
			velocity.y = direction * speed
	move_and_slide()
	
	#Si hay colision con un muro, que se de la vuelta
	if patrol_mode == PatrolMode.HORIZONTAL and is_on_wall():
		direction *= -1
	elif patrol_mode == PatrolMode.VERTICAL:
		if is_on_ceiling() or is_on_floor():
			direction *= -1
		

#Si detecta otras areas, hay que usar area_entered
func _on_attack_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		area.get_parent().take_damage(damage, global_position, knockback)
