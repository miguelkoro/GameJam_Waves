extends Node2D
class_name FlameStream

@onready var particles: GPUParticles2D = $GPUParticles2D
@onready var damage_area: Area2D = $DamageArea
@onready var collision_shape: CollisionShape2D = $DamageArea/CollisionShape2D

# Configuración del alcance del lanzagatos
@export var flame_length: float = 150.0  # Longitud de la llama
@export var flame_width: float = 60.0    # Ancho de la llama

var damage: int = 5
var damage_interval: float = 0.15
var can_damage: bool = true
var is_active: bool = false

# Diccionario para trackear cooldown de daño por enemigo
var enemy_cooldowns: Dictionary = {}

func _ready() -> void:
	# Asegurar que todo empieza apagado
	particles.emitting = false
	damage_area.monitoring = false
	
	# Configurar el CollisionShape para que sea alargado
	_setup_collision_shape()
	
	# Conectar señales
	if not damage_area.area_entered.is_connected(_on_damage_area_entered):
		damage_area.area_entered.connect(_on_damage_area_entered)
	
	if not damage_area.body_entered.is_connected(_on_damage_body_entered):
		damage_area.body_entered.connect(_on_damage_body_entered)

func _setup_collision_shape() -> void:
	if not collision_shape:
		push_warning("No hay CollisionShape2D en FlameStream!")
		return
	
	# Crear o configurar un RectangleShape2D alargado
	var rect_shape = collision_shape.shape as RectangleShape2D
	if not rect_shape:
		rect_shape = RectangleShape2D.new()
		collision_shape.shape = rect_shape
	
	# Configurar el tamaño: ancho x largo
	rect_shape.size = Vector2(flame_length, flame_width)
	
	# Posicionar el shape para que se extienda desde el muzzle hacia adelante
	# El centro del rectángulo está en flame_length/2
	collision_shape.position = Vector2(flame_length / 2, 0)

func _process(_delta: float) -> void:
	# Limpiar enemigos que ya no están en el área
	if is_active:
		_cleanup_old_cooldowns()

func start_flame(dmg: int) -> void:
	damage = dmg
	is_active = true
	particles.emitting = true
	particles.restart()
	damage_area.monitoring = true
	enemy_cooldowns.clear()

func stop_flame() -> void:
	is_active = false
	particles.emitting = false
	damage_area.monitoring = false
	enemy_cooldowns.clear()

func _on_damage_area_entered(area: Area2D) -> void:
	if not is_active:
		return
	
	# Verificar si es un enemigo
	if not area.is_in_group("Enemy"):
		return
	
	var enemy = area.get_parent()
	if not enemy or not enemy.has_method("take_damage"):
		return
	
	# Sistema de cooldown por enemigo individual
	var enemy_id = enemy.get_instance_id()
	
	# Si el enemigo está en cooldown, no hacer daño
	if enemy_cooldowns.has(enemy_id):
		return
	
	# Aplicar daño
	enemy.take_damage(damage, global_position, 20.0)
	
	# Iniciar cooldown para este enemigo específico
	enemy_cooldowns[enemy_id] = Time.get_ticks_msec()
	
	# Timer para quitar el cooldown
	await get_tree().create_timer(damage_interval).timeout
	enemy_cooldowns.erase(enemy_id)

# Nueva función para detectar también CharacterBody2D directamente
func _on_damage_body_entered(body: Node2D) -> void:
	if not is_active:
		return
	
	# Si es un enemigo CharacterBody2D directamente
	if body.is_in_group("Enemy") and body.has_method("take_damage"):
		var enemy_id = body.get_instance_id()
		
		if enemy_cooldowns.has(enemy_id):
			return
		
		body.take_damage(damage, global_position, 20.0)
		
		enemy_cooldowns[enemy_id] = Time.get_ticks_msec()
		await get_tree().create_timer(damage_interval).timeout
		enemy_cooldowns.erase(enemy_id)

func _cleanup_old_cooldowns() -> void:
	# Limpiar enemigos que ya no existen o están muy lejos
	var current_time = Time.get_ticks_msec()
	var to_remove = []
	
	for enemy_id in enemy_cooldowns.keys():
		var enemy = instance_from_id(enemy_id)
		if not enemy:
			to_remove.append(enemy_id)
	
	for id in to_remove:
		enemy_cooldowns.erase(id)
