extends Area2D
class_name Bullet

# Referencias OPCIONALES (no todas las balas las tendrán)
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var lifetime_timer: Timer = $Timer

# Propiedades
@export var max_lifetime: float = 3.0
var speed: float = 500.0
var damage: int = 10
var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	# Conectar señales
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	
	# Configurar timer de vida
	lifetime_timer.wait_time = max_lifetime
	lifetime_timer.one_shot = true
	lifetime_timer.timeout.connect(_on_lifetime_timeout)
	lifetime_timer.start()

func _process(delta: float) -> void:
	# Mover la bala
	position += direction.normalized() * speed * delta

# Función para inicializar la bala (llamada desde el arma)
func initialize(bullet_speed: float, bullet_damage: int) -> void:
	speed = bullet_speed
	damage = bullet_damage
	direction = Vector2.RIGHT.rotated(rotation)

# Cuando colisiona con un área (enemigos, etc.)
func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		area.take_damage(damage, global_position, 0)  # ← Añadí parámetros que tu enemigo necesita
	_destroy()

# Cuando colisiona con un cuerpo (paredes, etc.)
func _on_body_entered(body: Node2D) -> void:
	_destroy()

# Cuando se acaba el tiempo de vida
func _on_lifetime_timeout() -> void:
	_destroy()

# Destruir la bala
func _destroy() -> void:
	queue_free()
