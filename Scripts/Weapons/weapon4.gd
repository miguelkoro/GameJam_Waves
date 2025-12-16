extends Weapon
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sword_hitbox: Area2D = $AnimatedSprite2D/SwordHitbox
@onready var collision_shape_2d: CollisionShape2D = $AnimatedSprite2D/SwordHitbox/CollisionShape2D
@onready var audio_swing: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var chain: Line2D = $Line2D
@onready var chain_origin: Marker2D = $MuzzlePosition

# Propiedades de la espada
@export var attack_distance: float = 120.0  # Qué tan lejos llega la espada
@export var attack_duration: float = 0.6    # Duración total del ataque (ida + vuelta)
@export var return_speed_multiplier: float = 1.5  # La vuelta es más rápida

var is_attacking: bool = false
var attack_tween: Tween
var original_position: Vector2
var enemies_hit: Array = []  # Para evitar golpear al mismo enemigo múltiples veces

func _ready() -> void:
	super._ready()
	
	# Configurar como arma cuerpo a cuerpo
	weapon_name = "Espada Caos"
	weapon_type = WeaponType.MELEE
	damage = 30
	fire_rate = 1  # Cooldown entre ataques
	chain.visible = false
	chain.clear_points()
	chain.add_point(Vector2.ZERO)
	chain.add_point(Vector2.ZERO)

	# Guardar posición original
	if animated_sprite:
		original_position = animated_sprite.position
		animated_sprite.play("idle")
	
	# Desactivar hitbox al inicio
	if sword_hitbox:
		sword_hitbox.monitoring = false
		sword_hitbox.area_entered.connect(_on_sword_hit_area)
		sword_hitbox.body_entered.connect(_on_sword_hit_body)

func _process(delta: float) -> void:
	super._process(delta)
	
	# Actualizar animación según estado
	if not is_attacking and animated_sprite:
		animated_sprite.play("idle")
	if is_attacking and chain:
		chain.visible = true
		var p0 = chain.to_local(chain_origin.global_position)
		var p1 = chain.to_local(animated_sprite.global_position)
		chain.set_point_position(0, p0)
		chain.set_point_position(1, p1)

	else:
		if chain:
			chain.visible = false


# Sobrescribir el método shoot para el ataque de la espada
func shoot() -> void:
	if is_attacking or not can_shoot:
		return
	_attack_sword()

func _attack_sword() -> void:
	is_attacking = true
	can_shoot = false
	enemies_hit.clear()
	if animated_sprite:
		animated_sprite.play("moving")
	if audio_swing:
		audio_swing.play()
	
	# Activar hitbox
	if sword_hitbox:
		sword_hitbox.monitoring = true
	
	# Calcular posición objetivo (hacia el mouse)
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized()
	var target_global = global_position + direction * attack_distance
	var target_position = animated_sprite.get_parent().to_local(target_global)
	# Crear animación de ida y vuelta
	_animate_sword_attack(target_position)
	
func _animate_sword_attack(target_pos: Vector2) -> void:
	if attack_tween:
		attack_tween.kill()
	attack_tween = create_tween()
	attack_tween.set_parallel(false)
	var half_duration = attack_duration / 2.0
	# IDA - Lanzar la espada hacia el objetivo
	attack_tween.tween_property(animated_sprite, "position", target_pos, half_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	# Pequeña rotación durante el lanzamiento (opcional)
	attack_tween.parallel().tween_property(animated_sprite, "rotation_degrees", 360, half_duration)
	# VUELTA - Retornar la espada al jugador (más rápido)
	attack_tween.tween_property(animated_sprite, "position", original_position, half_duration / return_speed_multiplier).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	# Resetear rotación
	attack_tween.parallel().tween_property(animated_sprite, "rotation_degrees", 0, half_duration / return_speed_multiplier)
	# Al terminar el ataque
	attack_tween.tween_callback(_finish_attack)

func _finish_attack() -> void:
	is_attacking = false
	# Desactivar hitbox
	if sword_hitbox:
		sword_hitbox.monitoring = false
	# Volver a animación idle
	if animated_sprite:
		animated_sprite.play("idle")
		animated_sprite.rotation_degrees = 0
	# Reiniciar timer de cooldown
	if timer:
		timer.start()
	else:
		# Fallback sin timer
		await get_tree().create_timer(fire_rate).timeout
		can_shoot = true
		
# Detectar colisión con Area2D de enemigos
func _on_sword_hit_area(area: Area2D) -> void:
	if not area.is_in_group("Enemy"):
		return
	var enemy = area.get_parent()
	if enemy and enemy.has_method("take_damage"):
		_damage_enemy(enemy)

# Detectar colisión con CharacterBody2D de enemigos
func _on_sword_hit_body(body: Node2D) -> void:
	if not body.is_in_group("Enemy"):
		return
	if body.has_method("take_damage"):
		_damage_enemy(body)

func _damage_enemy(enemy: Node) -> void:
	# Evitar golpear al mismo enemigo múltiples veces en un ataque
	var enemy_id = enemy.get_instance_id()
	if enemy_id in enemies_hit:
		return
	enemies_hit.append(enemy_id)
	# Aplicar daño
	var knockback_force = 150.0
	enemy.take_damage(damage, global_position, knockback_force)

func _flip_sprite() -> void:
	if not animated_sprite:
		return
	var mouse_pos = get_global_mouse_position()
	var player_pos = get_parent().get_parent().global_position
	animated_sprite.flip_h = mouse_pos.x < player_pos.x

# Método helper para cancelar ataque (si el jugador recibe daño, etc.)
func cancel_attack() -> void:
	if attack_tween:
		attack_tween.kill()
	is_attacking = false
	if animated_sprite:
		animated_sprite.position = original_position
		animated_sprite.rotation_degrees = 0
		animated_sprite.play("idle")
	if sword_hitbox:
		sword_hitbox.monitoring = false
	can_shoot = true
