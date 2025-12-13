extends CharacterBody2D

@export var damage: float = 0.5
@export var speed: float = 40.0
@export var knockback: float = 100.0
@export var health: float = 3

# Movimiento aleatorio cuando no ve al player
@export var min_dir_time: float = 0.3
@export var max_dir_time: float = 0.8

# Distancia a la que detecta al jugador
@export var detection_radius: float = 150.0

# Escena de la tinta
@export var ink_scene: PackedScene
@export var ink_cooldown: float = 2.6

var external_force: Vector2 = Vector2.ZERO
var move_dir: Vector2 = Vector2.ZERO
var player: Node2D = null
var can_shoot: bool = true

@onready var detection_area: Area2D = $DetectionArea
@onready var detection_shape: CollisionShape2D = $DetectionArea/CollisionShape2D
@onready var change_dir_timer: Timer = $ChangeDirTimer
@onready var shoot_timer: Timer = $ShootTimer
@onready var ink_spawn_point: Marker2D = $InkSpawnPoint
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var shadow: Node2D = $Shadow
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


const ENEMY_DEATH = preload("uid://bcnpf5g14p543")
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_decay: float = 50.0 # Qué rápido se frena el knockback
@onready var audio_hit: AudioStreamPlayer2D = $AudioStreamPlayer_hit

func _ready() -> void:
	randomize()

	# Ajustar radio de detección si es un CircleShape2D
	var shape := detection_shape.shape
	if shape is CircleShape2D:
		shape.radius = detection_radius

	_choose_new_direction()
	_restart_change_dir_timer()



func _physics_process(delta: float) -> void:
	if knockback_velocity.length() > 1:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * delta)
	else:
	# SIEMPRE se mueve con movimiento aleatorio, independientemente del player
		var base_velocity: Vector2 = move_dir * speed
		velocity = base_velocity + external_force

	move_and_slide()

	external_force = external_force.move_toward(Vector2.ZERO, 180 * delta)



func _process(delta: float) -> void:
	if player != null and can_shoot:
		_shoot_ink_at_player()



# ------------------------------------
#   MOVIMIENTO ALEATORIO MEJORADO
# ------------------------------------
func _choose_new_direction() -> void:
	var new_dir := Vector2.ZERO

	# Evitar vectores casi nulos
	while new_dir.length() < 0.3:
		new_dir = Vector2.from_angle(randf() * TAU)

	move_dir = new_dir.normalized()


func _restart_change_dir_timer() -> void:
	change_dir_timer.wait_time = randf_range(min_dir_time, max_dir_time)
	change_dir_timer.start()



func _on_change_dir_timer_timeout() -> void:
	# Aunque haya player, sigue cambiando de dirección aleatoriamente
	_choose_new_direction()
	_restart_change_dir_timer()



# ------------------------------------
#   DETECCIÓN DEL PLAYER
# ------------------------------------
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body


func _on_detection_area_body_exited(body: Node2D) -> void:
	if player == body:
		player = null



# ------------------------------------
#   DISPARO DE TINTA
# ------------------------------------
func _shoot_ink_at_player() -> void:
	if ink_scene == null:
		return

	can_shoot = false
	animated_sprite_2d.play("attack")
	var ink: Area2D = ink_scene.instantiate()
	get_parent().add_child(ink)

	ink.global_position = ink_spawn_point.global_position

	var dir_to_player: Vector2 = (player.global_position - global_position).normalized()
	ink.setup(dir_to_player, damage, knockback)

	shoot_timer.start(ink_cooldown)


func _on_shoot_timer_timeout() -> void:
	can_shoot = true

func die() -> void:
	var death_effect = ENEMY_DEATH.instantiate()
	get_parent().add_child(death_effect)
	death_effect.global_position = global_position
	queue_free()
	pass
	
func take_damage(damage: float, attacker_pos: Vector2, attacker_knockback: float):
	if not audio_hit.playing:
		audio_hit.play()
	health-=damage
	# Knockback
	var direction = (global_position - attacker_pos).normalized()
	knockback_velocity = direction * attacker_knockback
	#flash_damage()
	if health <= 0:
		die()
	print("health:", health)


func _on_attack_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		area.get_parent().take_damage(damage, global_position, knockback)



func _on_animated_sprite_2d_animation_finished() -> void:
	animated_sprite_2d.play("idle")
