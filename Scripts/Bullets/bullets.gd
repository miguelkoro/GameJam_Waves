extends Area2D
class_name Bullet
@onready var collision_shape: CollisionShape2D = $CollisionShape2D if has_node("CollisionShape2D") else null
@onready var lifetime_timer: Timer = $Timer if has_node("Timer") else null
# Propiedades
@export var max_lifetime: float = 3.0
var speed: float = 500.0
var damage: int = 10
var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	add_to_group("PlayerBullet")
	collision_layer = 8   # 2^3 = Layer 4 (balas del jugador)
	collision_mask = 33   # Layers 1 y 6 (2^0 + 2^5 = 1 + 32 = 33)
	# Conectar señales
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	
	# Configurar timer de vida
	if lifetime_timer:
		lifetime_timer.wait_time = max_lifetime
		lifetime_timer.one_shot = true
		lifetime_timer.timeout.connect(_on_lifetime_timeout)
		lifetime_timer.start()

func _process(delta: float) -> void:
	position += direction.normalized() * speed * delta

func initialize(bullet_speed: float, bullet_damage: int) -> void:
	speed = bullet_speed
	damage = bullet_damage
	direction = Vector2.RIGHT.rotated(rotation)

# Cuando colisiona con un área (hitbox de los enemigos AttackHitBox)
func _on_area_entered(area: Area2D) -> void:
	print("DEBUG: Bala chocó con Area2D: ", area.name, " | Grupos: ", area.get_groups())
	
	# Si el área pertenece a un enemigo
	if area.is_in_group("Enemy"):
		# El parent del Area2D es el CharacterBody2D del enemigo
		var enemy = area.get_parent()
		if enemy and enemy.has_method("take_damage"):
			enemy.take_damage(damage, global_position, 50.0)  # 50 de knockback de la bala
		_destroy()

# Cuando colisiona con un cuerpo (paredes, tiles, enemigos CharacterBody2D)
func _on_body_entered(body: Node2D) -> void:	
	# Si choca con un enemigo (CharacterBody2D en Layer 3)
	if body.is_in_group("Enemy") and body.has_method("take_damage"):
		body.take_damage(damage, global_position, 50.0)
		_destroy()
	# Si choca con TileMapLayer...
	elif body is TileMapLayer:
		_destroy()
	# Si choca con paredes WorldCollider...
	elif body is StaticBody2D or body.is_in_group("WorldCollider"):
		_destroy()
	# No destruir si choca con el jugador (Layer 2)
	elif not body.is_in_group("Player"):
		_destroy()

# Cuando se acaba el tiempo de vida
func _on_lifetime_timeout() -> void:
	_destroy()

# Destruir la bala
func _destroy() -> void:
	queue_free()
