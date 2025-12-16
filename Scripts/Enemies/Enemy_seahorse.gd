extends CharacterBody2D

@export var patrol_speed := 40.0
@export var charge_speed := 120.0
@export var damage := 1.0
@export var knockback := 120.0
@export var health := 3.0

enum State { PATROL, CHARGE, STUNNED, DEAD }
var state := State.PATROL

enum Axis { HORIZONTAL, VERTICAL }
var axis := Axis.HORIZONTAL
var direction := 1

var player: Node2D = null
var charge_direction := Vector2.ZERO

const ENEMY_DEATH = preload("uid://bcnpf5g14p543")
const DAMAGE_PARTICLES = preload("uid://onmuslgsuqmh")

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player_damage: AnimationPlayer = $AnimationPlayer_Damage

@onready var stun_timer: Timer = $StunTimer
@onready var audio_hit: AudioStreamPlayer2D = $AudioStreamPlayer_hit
@onready var audio_charge: AudioStreamPlayer2D = $AudioStreamPlayer_Charge

func _ready():
	randomize()
	_pick_random_axis()
	_duplicate_material()
	
func _duplicate_material():
	if sprite_2d.material:
		sprite_2d.material = sprite_2d.material.duplicate()

func _pick_random_axis():
	axis = Axis.HORIZONTAL if randf() < 0.5 else Axis.VERTICAL
	direction = [-1, 1].pick_random()
	
func _handle_patrol_collision():
	if is_on_wall() or is_on_floor() or is_on_ceiling():
		direction *= -1

		# Cambio aleatorio de eje
		if randf() < 0.6:
			_pick_random_axis()
	
func _patrol_move():
	if axis == Axis.HORIZONTAL:
		velocity = Vector2(direction * patrol_speed, 0)
	else:
		velocity = Vector2(0, direction * patrol_speed)
		
func _physics_process(delta: float) -> void:
	

	
	match state:
		State.PATROL:
			_patrol_move()
		State.CHARGE:
			velocity = charge_direction * charge_speed
		State.STUNNED, State.DEAD:
			velocity = Vector2.ZERO
	move_and_slide()
	if state == State.PATROL:
		_handle_patrol_collision()

	if state == State.CHARGE and (is_on_wall() or is_on_floor() or is_on_ceiling()):
		_enter_stunned()
		
	#if state == State.PATROL and player:
	#	_start_charge()
	
	_animate()
	



func play_anim(name: String):
	if animation_player.current_animation != name:
		animation_player.play(name)

func _animate():
	if velocity.length() < 1:
		return

	if abs(velocity.x) > abs(velocity.y):
		if velocity.x > 0:
			play_anim("idle_right")
		else:
			play_anim("idle_left")
	else:
		if velocity.y > 0:
			play_anim("idle_front")
		else:
			play_anim("idle_back")

func _enter_stunned():
	state = State.STUNNED
	audio_charge.stop()
	stun_timer.start()

func _on_stun_timer_timeout():
	_pick_random_axis()
	state = State.PATROL

#Si detecta otras areas, hay que usar area_entered
func _on_attack_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		area.get_parent().take_damage(damage, global_position, knockback)
		if state == State.CHARGE:
			_enter_stunned()

func take_damage(damage: float, attacker_pos: Vector2, attacker_knockback: float):
	if state == State.DEAD:
		return
	if not audio_hit.playing:
		audio_hit.play()
	health-=damage
	animation_player_damage.play("damage")
	
	var particles = DAMAGE_PARTICLES.instantiate()
	particles.global_position = global_position
	get_parent().add_child(particles)
	
	# Knockback
	#var direction = (global_position - attacker_pos).normalized()
	#knockback_velocity = direction * attacker_knockback
	#flash_damage()
	if health <= 0:
		die()
	#print("health:", health)

func die() -> void:
	var death_effect = ENEMY_DEATH.instantiate()
	get_parent().add_child(death_effect)
	death_effect.global_position = global_position
	death_effect.countEnemy = true
	queue_free()

func _on_detection_area_body_entered(body):
	if state != State.PATROL:
		return
	if body.is_in_group("Player"):
		player = body
				# 🔴 COMPROBAMOS VISIÓN
		if _has_line_of_sight_to_player():
			_start_charge()

#Comprobar que no hay obstaculos de por medio entre jugador y caballito,porque entonces no embiste
func _has_line_of_sight_to_player() -> bool:
	if not player:
		return false
	var space_state = get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(
		global_position,
		player.global_position
	)
	# Ignorarse a sí mismo
	query.exclude = [self]
	var result = space_state.intersect_ray(query)

	# Si no golpea nada → visión libre
	if result.is_empty():
		return true

	# Si golpea algo, solo es válido si es el jugador
	if result.collider.is_in_group("Player"):
		return true

	# Si golpea WorldCollider → bloqueado
	if result.collider.is_in_group("WorldCollider"):
		return false

	return false

func _on_detection_area_body_exited(body):
	if body == player:
		player = null
		
func _start_charge():
	if state != State.PATROL:
		return
	state = State.CHARGE
	audio_charge.play()
	charge_direction = (player.global_position - global_position).normalized()

func flash_damage():
	var mat := sprite_2d.material
	mat.set("shader_param/hit_flash", 1.0)
	await get_tree().create_timer(0.12).timeout
	mat.set("shader_param/hit_flash", 0.0)
