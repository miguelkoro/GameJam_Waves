extends CharacterBody2D
var direction: Vector2 = Vector2.ZERO
var attacking: bool = false
var moving: bool = false
var external_force: Vector2 = Vector2.ZERO #Esto lo uso para poder mover al personaje en aguas con corriente


func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_dir != Vector2.ZERO:
		moving = true
	else:
		moving = false
	#Añado la fuerza externa, si es afectado
	var base_speed = input_dir.normalized() * PlayerStats.agility
	#base_speed += external_force
	#velocity += external_force
	velocity = base_speed + external_force
	
	#velocity = input_dir.normalized() * PlayerStats.agility
	move_and_slide()
	
	#Quito la fuerza externa para que no se acumule
	external_force = external_force.move_toward(Vector2.ZERO, 100 * delta)
