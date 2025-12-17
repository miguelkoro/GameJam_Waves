extends Node2D
class_name FlameStream

@onready var particles: GPUParticles2D = $GPUParticles2D
@onready var damage_area: Area2D = $DamageArea
@onready var collision_shape: CollisionShape2D = $DamageArea/CollisionShape2D

# Configuración del alcance del lanzagatos
@export var flame_length: float = 150.0
@export var flame_width: float = 60.0

var damage: int = 5
var damage_interval: float = 0.15
var is_active: bool = false

# Diccionario para trackear cooldown de daño por enemigo
var enemy_cooldowns: Dictionary = {}
var enemies_in_area: Dictionary = {}  # enemy_id -> enemy_node

func _ready() -> void:
	particles.emitting = false
	damage_area.monitoring = false
	
	_setup_collision_shape()
	
	# Conectar señales de entrada Y salida
	damage_area.area_entered.connect(_on_damage_area_entered)
	damage_area.body_entered.connect(_on_damage_body_entered)
	damage_area.area_exited.connect(_on_damage_area_exited)
	damage_area.body_exited.connect(_on_damage_body_exited)

func _setup_collision_shape() -> void:
	if not collision_shape:
		push_warning("No hay CollisionShape2D en FlameStream!")
		return
	
	var rect_shape = collision_shape.shape as RectangleShape2D
	if not rect_shape:
		rect_shape = RectangleShape2D.new()
		collision_shape.shape = rect_shape
	
	rect_shape.size = Vector2(flame_length, flame_width)
	collision_shape.position = Vector2(flame_length / 2, 0)

func _process(delta: float) -> void:
	if is_active:
		_apply_continuous_damage()

func _apply_continuous_damage() -> void:
	var current_time = Time.get_ticks_msec()
	
	# Iterar sobre enemigos que están actualmente en el área
	for enemy_id in enemies_in_area.keys():
		var enemy = enemies_in_area[enemy_id]
		
		# Verificar que el enemigo sigue existiendo
		if not is_instance_valid(enemy):
			enemies_in_area.erase(enemy_id)
			enemy_cooldowns.erase(enemy_id)
			continue
		
		# Verificar cooldown
		if enemy_cooldowns.has(enemy_id):
			var time_since_last = current_time - enemy_cooldowns[enemy_id]
			# Convertir damage_interval a milisegundos
			if time_since_last < (damage_interval * 1000):
				continue
		
		# Aplicar daño
		if enemy.has_method("take_damage"):
			enemy.take_damage(damage, global_position, 20.0)
			enemy_cooldowns[enemy_id] = current_time

func start_flame(dmg: int) -> void:
	damage = dmg
	is_active = true
	particles.emitting = true
	particles.restart()
	damage_area.monitoring = true
	enemy_cooldowns.clear()
	enemies_in_area.clear()

func stop_flame() -> void:
	is_active = false
	particles.emitting = false
	damage_area.monitoring = false
	enemy_cooldowns.clear()
	enemies_in_area.clear()

# Cuando un Area2D entra
func _on_damage_area_entered(area: Area2D) -> void:
	if not is_active or not area.is_in_group("Enemy"):
		return
	
	var enemy = area.get_parent()
	if enemy and enemy.has_method("take_damage"):
		var enemy_id = enemy.get_instance_id()
		enemies_in_area[enemy_id] = enemy

# Cuando un CharacterBody2D entra
func _on_damage_body_entered(body: Node2D) -> void:
	if not is_active:
		return
	
	if body.is_in_group("Enemy") and body.has_method("take_damage"):
		var enemy_id = body.get_instance_id()
		enemies_in_area[enemy_id] = body

# Cuando un Area2D sale
func _on_damage_area_exited(area: Area2D) -> void:
	if not area.is_in_group("Enemy"):
		return
	
	var enemy = area.get_parent()
	if enemy:
		var enemy_id = enemy.get_instance_id()
		enemies_in_area.erase(enemy_id)
		enemy_cooldowns.erase(enemy_id)

# Cuando un CharacterBody2D sale
func _on_damage_body_exited(body: Node2D) -> void:
	if not body.is_in_group("Enemy"):
		return
	
	var enemy_id = body.get_instance_id()
	enemies_in_area.erase(enemy_id)
	enemy_cooldowns.erase(enemy_id)
