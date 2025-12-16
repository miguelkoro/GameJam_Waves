extends CharacterBody2D

@export var damage: float = 0.5
@export var speed: float = 80
@export var knockback: float = 100
@export var spike_shoot_interval: float = 6.0  
@export var spike_speed: float = 160
@export var health: float = 300

var spike_scene: PackedScene = load("res://Scenes/spike.tscn")
const ENEMY_DEATH = preload("uid://bcnpf5g14p543")
var direction: Vector2 = Vector2.ONE.normalized() 
var shoot_timer: float = 0.0
var external_force: Vector2 = Vector2.ZERO  
var shooting: bool = false
@onready var icon: Sprite2D = $Icon
@onready var audio_hit: AudioStreamPlayer2D = $AudioStreamPlayer_hit

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_decay: float = 50.0 # Qué rápido se frena el knockback
@onready var animation_player_damage: AnimationPlayer = $AnimationPlayer_Damage
const DAMAGE_PARTICLES = preload("uid://onmuslgsuqmh")

func _ready() -> void:
	randomize()
	var angle = randf() * TAU 
	direction = Vector2(cos(angle), sin(angle)).normalized()

func _physics_process(delta: float) -> void:
	if knockback_velocity.length() > 1:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * delta)
	else:
		velocity = direction * speed
	move_and_slide()
	if is_on_wall():
		direction.x *= -1
	if is_on_floor() or is_on_ceiling():
		direction.y *= -1
	
	shoot_timer += delta
	if shoot_timer >= spike_shoot_interval:
		shoot_spikes()
		shoot_timer = 0.0

func shoot_spikes() -> void:
	if spike_scene == null:
		return
	animation_player.play("Attack")
	
	
	for i in range(8):
		var angle = i * PI / 4 
		var spike_direction = Vector2(cos(angle), sin(angle))
		
		var spike = spike_scene.instantiate()
		get_parent().add_child(spike)
		spike.global_position = global_position
		
		
		if spike.has_method("set_shooter"):
			spike.set_shooter(self)
		if spike.has_method("set_direction"):
			spike.set_direction(spike_direction, spike_speed)
		elif "velocity" in spike:
			spike.velocity = spike_direction * spike_speed
		elif "direction" in spike and "speed" in spike:
			spike.direction = spike_direction
			spike.speed = spike_speed

func _on_attack_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		area.get_parent().take_damage(damage, global_position, knockback)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Attack":
		if direction.x > 0:
			animation_player.play("idle_Right")
		else: 
			animation_player.play("idle_Left")

func take_damage(damage: float, attacker_pos: Vector2, attacker_knockback: float):
	if not audio_hit.playing:
		audio_hit.play()
	health-=damage
	animation_player_damage.play("damage")
	
	var particles = DAMAGE_PARTICLES.instantiate()
	particles.global_position = global_position
	get_parent().add_child(particles)
	
	# Knockback
	var direction = (global_position - attacker_pos).normalized()
	knockback_velocity = direction * attacker_knockback
	#direction *= -1
	if health <= 0:
		die()
	print("health:", health)

func die() -> void:
	var death_effect = ENEMY_DEATH.instantiate()
	get_parent().add_child(death_effect)
	death_effect.global_position = global_position
	queue_free()
	pass
