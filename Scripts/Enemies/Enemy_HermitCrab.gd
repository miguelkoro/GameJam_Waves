extends CharacterBody2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

@export var damage: float = 1
@export var speed: float = 50
@export var direction: int = 1
@export var knockback: float = 100 #Efecto de echar para atras al jugador al golpearle
@export var health: float = 3
@export var hidding: bool = true #Para ver cuando esta oculto y por tanto es inmortal
@export var hide_lock: bool = false #Si lo golpeas mientras esta escondido, se mantendrá oculto otro poco
@export var player_near: bool = false #Para detectar si el jugador esta cerca
var player: Node2D #Posicion del jugador para ir a por el
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_decay: float = 50.0 # Qué rápido se frena el knockback
@onready var audio_hit: AudioStreamPlayer2D = $AudioStreamPlayer_hit
const ENEMY_DEATH = preload("uid://bcnpf5g14p543")

		
func _physics_process(delta: float) -> void:	
	#move_and_slide()
	if hide_lock:
		return
	#Si el jugador esta en el area de deteccion, procedemos a mirar si el cangrejo sale de su roca y se oculta (probabilidad del 10%)
	if !player_near and randf() <= 0.001:
		enemy_appear_and_hide()
	if !player_near and hidding:
		return
	if player_near and hidding: #si el jugador esta cerca y el cangrejo esta escondido
		await get_tree().create_timer(randf_range(2.0, 4.0)).timeout #Le ponemos tiempo random y hacemos que salga
		enemy_appear()

	if player_near and !hidding:
		#Si el jugador esta cerca y el cangrejo esta fuera, el cangrejo ira a por el jugador
		#Falta ponerle el movimiento con el navigationAgent
		if knockback_velocity.length() > 1:
			velocity = knockback_velocity
			knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * delta)
			move_and_slide()
		else:
			navigation_agent.target_position = player.global_position
			navigate_safe()
		
	
	
		

func enemy_hide(): #Se sale de la roca
	if hidding:
		return
	animated_sprite.play("hide")
	hidding = true

func enemy_appear(): #Se oculta en la roca
	if !hidding or hide_lock:
		return
	animated_sprite.play("appear")
	hidding = false

func enemy_appear_and_hide():
	animated_sprite.play("appear_hide")


#Si detecta otras areas, hay que usar area_entered
func _on_attack_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		area.get_parent().take_damage(damage, global_position, knockback)

func take_damage(damage: float, attacker_pos: Vector2, attacker_knockback: float):
	if !hidding:
		if not audio_hit.playing:
			audio_hit.play()
		health-=damage
		# Knockback
		var direction = (global_position - attacker_pos).normalized()
		knockback_velocity = direction * attacker_knockback
		#flash_damage()
		
		if health <= 0:
			die()
	else:
		hide_lock = true
		await get_tree().create_timer(3.0).timeout #espero 3seg para poder salir de nuevo
		hide_lock = false



func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_near = true
		player=body #Coge al jugador para poder perseguirle


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):	
		player_near = false
		enemy_hide()
		navigation_agent.target_position = get_parent().global_position#Se para en la posicion actual
		navigation_agent.velocity = Vector2.ZERO

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

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	position += safe_velocity * get_physics_process_delta_time()
