extends Area2D

@export var speed: float = 180.0
@export var lifetime: float = 3.0
const INK_SPLASH = preload("uid://cfveuxic7ufkk")


var direction: Vector2 = Vector2.ZERO
var damage: float = 0.5
var knockback: float = 0.0

func setup(dir: Vector2, p_damage: float, p_knockback: float) -> void:
	direction = dir.normalized()
	damage = p_damage
	knockback = p_knockback

func _ready() -> void:
	# Autodestruirse después de un tiempo para no dejar basura
	await get_tree().create_timer(lifetime).timeout
	if is_inside_tree():
		queue_free()

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		# Daño al jugador
		if body.has_method("take_damage"):
			body.take_damage(damage, global_position, knockback)
			#Mancharse de tinta (Necesita que haya el ScreenEffects)
			PlayerStats.screen_ink_effect() #Para darle efecto de mancharse de tinta	
			ink_splash()	
		# Pantalla negra
		#if body.has_method("black_out_screen"):
		#	body.black_out_screen()

		queue_free()
	elif body.is_in_group("World"):
	#elif body.get_collision_layer() & (1 << 1): #Valor de World
		# Choca con el escenario
		ink_splash()
		queue_free()
func ink_splash() -> void:
	var inkSplash = INK_SPLASH.instantiate()
	inkSplash.global_position = global_position
	get_parent().add_child(inkSplash)
