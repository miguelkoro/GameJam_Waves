extends CharacterBody2D
#Variables para las animaciones
var direction: Vector2 = Vector2.ZERO
var attacking: bool = false
var moving: bool = false
var hurt: bool = false

@export var invulnerabilityTime: float = 1.5 # Tiempo que es invulnerable
var external_force: Vector2 = Vector2.ZERO #Esto lo uso para poder mover al personaje en aguas con corriente
@onready var sprite_2d: Sprite2D = $Sprite2D #Para usar el shader del sprite y ponerle parpadeo cuando es invulnerable
@onready var screen_fade: ColorRect = $CanvasLayer/ScreenFade


func _physics_process(delta: float) -> void:
	# -------- MOVIMIENTO --------
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	moving = input_dir != Vector2.ZERO

	var base_speed = input_dir.normalized() * PlayerStats.agility
	velocity = base_speed + external_force
	move_and_slide()

	external_force = external_force.move_toward(Vector2.ZERO, 180 * delta)

	# -------- DIRECCIÓN HACIA EL RATÓN --------
	var mouse_pos = get_global_mouse_position()
	var to_mouse = (mouse_pos - global_position).normalized()

	# Guardamos la dirección para las animaciones
	direction = to_mouse

func take_damage(damage: float, attacker_pos: Vector2, attacker_knockback: float):
	if hurt == true:
		return
	hurt = true
	#print("damage: ", damage)
	PlayerStats.take_damage(damage)
	#Aqui poner la accion de quitarle salud en el PlayerStats
	#sprite_2d.material.set_shader_parameter("active", invulnerabilityTime)
	sprite_2d.material.set_shader_parameter("mode", 1)
	sprite_2d.material.set_shader_parameter("intensity", 1.0)
	#Efecto de knockback al sufrir daño
	var knockback_dir = (global_position - attacker_pos).normalized()
	external_force = knockback_dir * attacker_knockback
	#Añadirle animacion y sonido de sufrir daño
	#Añadirle particulas de sufrir daño
	# Tiempo de invulnerabilidad
	var invul_time = 1.0
	await get_tree().create_timer(invul_time).timeout
	# Desactivar parpadeo y fuerza externa del knockback
	sprite_2d.material.set_shader_parameter("intensity", 0.0)
	sprite_2d.material.set_shader_parameter("mode", 0)
	external_force = Vector2.ZERO
	hurt = false

func healing(amount: float):
	PlayerStats.healing(amount)
	sprite_2d.material.set_shader_parameter("mode", 2)
	sprite_2d.material.set_shader_parameter("intensity", 1.0)

	await get_tree().create_timer(0.4).timeout
	sprite_2d.material.set_shader_parameter("intensity", 0.0)
	sprite_2d.material.set_shader_parameter("mode", 0)
	
	
func black_out_screen() -> void:
	print("BLACK OUT LLAMADO")

	# Nos aseguramos de que el color base es negro opaco
	var base_color := screen_fade.color
	base_color.a = 1.0
	screen_fade.color = base_color

	# Empezamos desde totalmente transparente (a nivel de modulate)
	var mod := screen_fade.modulate
	mod.a = 0.0
	screen_fade.modulate = mod

	var tween := create_tween()

	# Negro semitransparente (por ejemplo 0.6)
	var target_alpha := 0.6

	# Fundido rápido a negro transparente
	tween.tween_property(screen_fade, "modulate:a", target_alpha, 0.2)

	# Mantenerlo un poco
	tween.tween_interval(0.5)

	# Volver a transparente
	tween.tween_property(screen_fade, "modulate:a", 0.0, 0.4)
