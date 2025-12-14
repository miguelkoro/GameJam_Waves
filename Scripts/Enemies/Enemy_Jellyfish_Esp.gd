extends CharacterBody2D

@export var damage: float = 1
#@export var speed: float = 50
@export var direction: Vector2 = Vector2.ZERO
@export var knockback: float = 100 #Efecto de echar para atras al jugador al golpearle
@export var health: float = 3

enum State {WANDER, CHASE, ARMING, DEAD}
var state: State = State.WANDER
@export var wander_speed: float = 40
@export var chase_speed: float = 70
var player: Node2D = null

enum PatrolMode {HORIZONTAL, VERTICAL}
@export var patrol_mode: PatrolMode = PatrolMode.VERTICAL
const ENEMY_DEATH = preload("uid://csqr4g8qay5p2")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_decay: float = 50.0 # Qué rápido se frena el knockback
@onready var audio_hit: AudioStreamPlayer2D = $AudioStreamPlayer_hit
@onready var explosion_timer: Timer = $ExplosionTimer

@export var min_wander_time := 1.0
@export var max_wander_time := 3.0
@onready var wander_timer: Timer = $WanderTimer
@onready var explosion_area: Area2D = $ExplosionArea

func _ready() -> void:
	randomize()
	_start_wander()
	var mat := animated_sprite.material
	animated_sprite.material = mat.duplicate()

func _restart_wander_timer():
	wander_timer.wait_time = randf_range(min_wander_time, max_wander_time)
	wander_timer.start()

func _start_wander():
	state = State.WANDER
	_pick_random_direction()
	_restart_wander_timer()
	
func _physics_process(delta: float) -> void:
	#Movemos horizontalmente el enemigo
	#velocity.x = direction * speed
	#velocity.y = 0
	#if knockback_velocity.length() > 1:
	#	velocity = knockback_velocity
	#	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * delta)
	#else:
	match state:
		State.WANDER:				
			velocity = direction * wander_speed
			if is_on_wall() or is_on_ceiling() or is_on_floor():
				_pick_random_direction()
		State.CHASE:
			if player:
				velocity = (player.global_position - global_position). normalized() * chase_speed
		State.ARMING:
			velocity = Vector2.ZERO
		State.DEAD:
			velocity = Vector2.ZERO
	move_and_slide()
	
	#Si hay colision con un muro, que se de la vuelta
	if patrol_mode == PatrolMode.HORIZONTAL and is_on_wall():
		direction *= -1
	elif patrol_mode == PatrolMode.VERTICAL:
		if is_on_ceiling() or is_on_floor():
			direction *= -1

	
func _pick_random_direction():
	var angle = randf() * TAU
	direction = Vector2(cos(angle), sin(angle)).normalized()

#Si detecta otras areas, hay que usar area_entered
func _on_attack_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		area.get_parent().take_damage(damage, global_position, knockback)

func take_damage(damage: float, attacker_pos: Vector2, attacker_knockback: float):
	if state == State.DEAD:
		return
	if not audio_hit.playing:
		audio_hit.play()
	health-=damage
	# Knockback
	var direction = (global_position - attacker_pos).normalized()
	knockback_velocity = direction * attacker_knockback
	flash_damage()
	if health <= 0:
		state = State.DEAD
		die()
	print("health:", health)

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and state == State.WANDER:
		player = body
		state = State.CHASE


		
func _process(delta: float) -> void:
	if state == State.CHASE and player:
		if global_position.distance_to(player.global_position) < 32:
			_start_arming()

func _start_arming():
	state = State.ARMING
	animated_sprite.play("arming")
	explosion_timer.start()

func die() -> void:
	var death_effect = ENEMY_DEATH.instantiate()
	get_parent().add_child(death_effect)
	death_effect.global_position = global_position
	death_effect.countEnemy = true
	queue_free()
	pass

func _on_explosion_timer_timeout():
	if state == State.DEAD:
		return
	state = State.DEAD
	_explode()

func _explode():
	for body in explosion_area.get_overlapping_bodies():
		if body.is_in_group("Player"):
			body.take_damage(2, global_position, 150)
	die()

func flash_damage():
	var mat := animated_sprite.material
	mat.set("shader_param/hit_flash", 1.0)
	await get_tree().create_timer(0.12).timeout
	mat.set("shader_param/hit_flash", 0.0)


func _on_wander_timer_timeout() -> void:
	if state == State.WANDER:
		_pick_random_direction()
		_restart_wander_timer()
