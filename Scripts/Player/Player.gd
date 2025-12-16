extends CharacterBody2D

#Sonidos de pasos #En agua y arena
@onready var audio_sand: AudioStreamPlayer2D = $AudioStreamPlayer_Sand
#Sonido de arañazo
@onready var audio_swing: AudioStreamPlayer2D = $AudioStreamPlayer_Swing
#Sonido de recibir daño
@onready var audio_hurt: AudioStreamPlayer2D = $AudioStreamPlayer_Hurt

#Variable para controlar cuando esta en la caja y no deberia moverse de ahi o no queremos que haga nada
@export var inactive: bool = false

#Variables para las animaciones
var direction: Vector2 = Vector2.ZERO
var attacking: bool = false
var moving: bool = false
var hurt: bool = false
var shooting: bool = false

@export var invulnerabilityTime: float = 1.5 # Tiempo que es invulnerable
var external_force: Vector2 = Vector2.ZERO #Esto lo uso para poder mover al personaje en aguas con corriente
@onready var sprite_2d: Sprite2D = $Sprite2D #Para usar el shader del sprite y ponerle parpadeo cuando es invulnerable
@onready var screen_fade: ColorRect = $CanvasLayer/ScreenFade
@onready var attack_hitbox: Area2D = $AttackHitbox
@onready var weapon_position: Marker2D = $WeaponPosition

var current_weapon: Weapon = null

func _ready() -> void:
	#Desactivo la hitbox de ataque para que solo se active al hacer click der
	attack_hitbox.visible = false
	attack_hitbox.monitoring = false
	
	#Equipar arma inicial (weapon1).
	equip_weapon(preload("res://Scenes/Weapons/weapon1.tscn"))

func _physics_process(delta: float) -> void:
	if inactive:
		return
	
		# -------- DIRECCIÓN HACIA EL RATÓN --------
	var mouse_pos = get_global_mouse_position()
	var to_mouse = (mouse_pos - global_position).normalized()
	# Guardamos la dirección para las animaciones
	direction = to_mouse
	
		# -------- ATAQUE CON GARRAS--------
	if Input.is_action_just_pressed("attack") and !attacking and !hurt:
		attack_hitbox.look_at(mouse_pos)
		attack()
		return  # Evita que se mueva mientras ataca
		
		# -------- DISPAROS DEL ARMA CON CLICK DERECHO --------
	if Input.is_action_just_pressed("shoot") and current_weapon and !hurt:
		shooting = true		
		current_weapon.shoot()
		await get_tree().create_timer(0.3).timeout
		shooting = false
	
	# -------- RECARGAR ARMA PULSANDO TECLA R -------- 
	#Implementar que aparezca una R cuando se acaben las balas.
	if Input.is_action_just_pressed("reload") and current_weapon and !hurt:
		current_weapon.reload()
	
	# -------- MOVIMIENTO --------
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	moving = input_dir != Vector2.ZERO
	var base_speed = input_dir.normalized() * PlayerStats.agility
	velocity = base_speed + external_force
	if(!moving):
		audio_sand.stop()
	if(!attacking): #Que no se mueva durante el ataque a mele??
		if(moving and not audio_sand.playing): #Que reproduzca sonido de pasos
			audio_sand.play()
		move_and_slide()

	#Le añadimos a
	external_force = external_force.move_toward(Vector2.ZERO, 180 * delta)

func equip_weapon(weapon_scene: PackedScene) -> void:
	# Eliminar arma anterior si existe
	if current_weapon:
		current_weapon.queue_free()
	
	# Instanciar nueva arma
	current_weapon = weapon_scene.instantiate()
	weapon_position.add_child(current_weapon)
	
	print("Arma equipada: ", current_weapon.weapon_name)

func take_damage(damage: float, attacker_pos: Vector2, attacker_knockback: float):
	if hurt == true:
		return
	hurt = true
	#print("damage: ", damage)
	PlayerStats.take_damage(damage)
	if not audio_hurt.playing:
		audio_hurt.play()
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
	
	
#func black_out_screen() -> void:
#	print("BLACK OUT LLAMADO")
	# Nos aseguramos de que el color base es negro opaco
#	var base_color := screen_fade.color
#	base_color.a = 1.0
#	screen_fade.color = base_color
	# Empezamos desde totalmente transparente (a nivel de modulate)
#	var mod := screen_fade.modulate
#	mod.a = 0.0
#	screen_fade.modulate = mod
#	var tween := create_tween()
	# Negro semitransparente (por ejemplo 0.6)
#	var target_alpha := 0.6
	# Fundido rápido a negro transparente
#	tween.tween_property(screen_fade, "modulate:a", target_alpha, 0.2)
	# Mantenerlo un poco
#	tween.tween_interval(0.5)
	# Volver a transparente
#	tween.tween_property(screen_fade, "modulate:a", 0.0, 0.4)

func attack():
	if attacking:
		return
	attacking = true
	#Activamos la hitbox de ataque
	attack_hitbox.visible = true
	attack_hitbox.monitoring = true
	if not audio_swing.playing:
		audio_swing.play()
	# Tiempo que dura el ataque (igual que la animación)
	await get_tree().create_timer(0.5).timeout
	#Desactivamos la hitbox de ataque
	attack_hitbox.visible = false
	attack_hitbox.monitoring = false
	attacking = false


func _on_attack_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemy"):
		area.get_parent().take_damage(PlayerStats.strenght, global_position, PlayerStats.knockback)


func _on_show_label_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
