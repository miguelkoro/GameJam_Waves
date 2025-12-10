extends CharacterBody2D

@export var damage: float = 1
@export var speed: float = 50
@export var direction: int = 1
@export var knockback: float = 100 #Efecto de echar para atras al jugador al golpearle
@export var health: float = 3



enum PatrolMode {HORIZONTAL, VERTICAL}
@export var patrol_mode: PatrolMode = PatrolMode.VERTICAL
const ENEMY_DEATH = preload("uid://bcnpf5g14p543")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_decay: float = 50.0 # Qué rápido se frena el knockback
@onready var audio_hit: AudioStreamPlayer2D = $AudioStreamPlayer_hit

func _ready() -> void:
	var r = randi_range(1,2)
	if r == 1:
		patrol_mode = PatrolMode.VERTICAL
	else:
		patrol_mode = PatrolMode.HORIZONTAL
		
func _physics_process(delta: float) -> void:
	#Movemos horizontalmente el enemigo
	#velocity.x = direction * speed
	#velocity.y = 0
	if knockback_velocity.length() > 1:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * delta)
	else:
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

func take_damage(damage: float, attacker_pos: Vector2, attacker_knockback: float):
	if not audio_hit.playing:
		audio_hit.play()
	health-=damage
	# Knockback
	var direction = (global_position - attacker_pos).normalized()
	knockback_velocity = direction * attacker_knockback
	flash_damage()
	if health <= 0:
		die()
	print("health:", health)

func die() -> void:
	var death_effect = ENEMY_DEATH.instantiate()
	get_parent().add_child(death_effect)
	death_effect.global_position = global_position
	queue_free()
	pass


func flash_damage():
	var mat := animated_sprite.material
	mat.set("shader_param/hit_flash", 1.0)
	await get_tree().create_timer(0.12).timeout
	mat.set("shader_param/hit_flash", 0.0)
