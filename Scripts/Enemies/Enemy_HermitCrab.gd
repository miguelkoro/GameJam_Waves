extends CharacterBody2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

@export var damage: float = 1
@export var speed: float = 50
@export var direction: int = 1
@export var knockback: float = 100 #Efecto de echar para atras al jugador al golpearle
@export var health: float = 5
@export var hidding: bool = true #Para ver cuando esta oculto y por tanto es inmortal
#@export var hide_lock: bool = false #Si lo golpeas mientras esta escondido, se mantendrá oculto otro poco
var hide_locked := false
@export var player_near: bool = false #Para detectar si el jugador esta cerca
var player: Node2D = null #Posicion del jugador para ir a por el
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_decay: float = 50.0 # Qué rápido se frena el knockback
@onready var audio_hit: AudioStreamPlayer2D = $AudioStreamPlayer_hit
const ENEMY_DEATH = preload("uid://bcnpf5g14p543")
enum State {
	HIDDEN,        # Dentro de la concha (invulnerable)
	PEEKING,       # Sale y se vuelve a esconder
	EMERGING,     # Sale tras detectar jugador
	CHASING,      # Persigue al jugador
	RETREATING,   # Se vuelve a esconder
	DEAD
}
var state: State = State.HIDDEN
@onready var idle_timer: Timer = $IdleTimer
@onready var reveal_timer: Timer = $RevealTimer
@onready var chase_timer: Timer = $ChaseTimer
@onready var hide_lock_timer: Timer = $HideLockTimer
@onready var animation_player_damage: AnimationPlayer = $AnimationPlayer_Damage
@onready var audio_inmortal: AudioStreamPlayer2D = $AudioStreamPlayer_Inmortal

const DAMAGE_PARTICLES = preload("uid://onmuslgsuqmh")


func _ready():
	state = State.HIDDEN
	idle_timer.start(randf_range(3.0, 5.0))

func _on_idle_timer_timeout():
	if state != State.HIDDEN or hide_locked:
		return
	if randf() < 0.1:
		state = State.PEEKING
		animated_sprite.play("appear_hide")
		await animated_sprite.animation_finished
		state = State.HIDDEN
	idle_timer.start(randf_range(3.0, 5.0))
	
func _on_reveal_timer_timeout():
	if state != State.EMERGING:
		return
	animated_sprite.play("appear")
	state = State.CHASING
	chase_timer.start(randf_range(2.0, 6.0))
	
func _on_chase_timer_timeout():
	if state == State.CHASING:
		_start_retreat()

func _start_retreat():
	state = State.RETREATING
	animated_sprite.play("hide")

func _on_animation_finished():
	if state == State.RETREATING:
		state = State.HIDDEN

		
func _physics_process(delta: float) -> void:	
	if state == State.CHASING and player:
		navigation_agent.target_position = player.global_position
		navigate_safe()
		if not navigation_agent.is_navigation_finished():
			var next_pos := navigation_agent.get_next_path_position()
			var dir := (next_pos - global_position).normalized()
			velocity = dir * speed
		else:
			velocity = Vector2.ZERO
	else:
		velocity = Vector2.ZERO

	move_and_slide()
		
	
#func _on_navigation_agent_2d_velocity_computed(safe_velocity):
#	if state != State.CHASING:
#		return
#	velocity = safe_velocity
		


#Si detecta otras areas, hay que usar area_entered
func _on_attack_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		area.get_parent().take_damage(damage, global_position, knockback)
		if state == State.CHASING:
			_start_retreat()

func take_damage(damage: float, attacker_pos: Vector2, attacker_knockback: float):
	
		# Knockback
		#var direction = (global_position - attacker_pos).normalized()
		#knockback_velocity = direction * attacker_knockback
		#flash_damage()
	# Si está oculto → invulnerable
	if state == State.HIDDEN:
		hide_locked = true
		hide_lock_timer.start(3.0)
		audio_inmortal.play()
		return

	# Si ya está muriendo, no hacer nada
	if state == State.DEAD:
		return
		
	var particles = DAMAGE_PARTICLES.instantiate()
	particles.global_position = global_position
	get_parent().add_child(particles)
	
	health -= damage
	audio_hit.play()
	animation_player_damage.play("damage")

	# Si sigue vivo → se esconde
	if health > 0:
		if state == State.CHASING or state == State.EMERGING:
			_start_retreat()
	else:
		die()




func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and state == State.HIDDEN and not hide_locked:
		player = body
		state = State.EMERGING
		reveal_timer.start(randf_range(1.0, 3.0))


func _on_detection_area_body_exited(body: Node2D) -> void:
	#if body.is_in_group("Player"):	
	#	player_near = false
	#	enemy_hide()
	#	navigation_agent.target_position = get_parent().global_position#Se para en la posicion actual
	#	navigation_agent.velocity = Vector2.ZERO
	if body == player:
		player = null
		if state == State.CHASING:
			_start_retreat()

func navigate_safe() -> void:
	if navigation_agent.is_navigation_finished():
		return
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	var new_velocity: Vector2 = (
		global_position.direction_to(next_path_position) * speed
	)
	navigation_agent.velocity = new_velocity
	
func die() -> void:
	var death_effect = ENEMY_DEATH.instantiate()
	get_parent().add_child(death_effect)
	death_effect.global_position = global_position
	death_effect.countEnemy = false
	queue_free()
	pass	

#func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
#	position += safe_velocity * get_physics_process_delta_time()


func _on_hide_lock_timer_timeout() -> void:
	hide_locked = false
