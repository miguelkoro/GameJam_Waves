extends Node2D
class_name Weapon

# Referencias a nodos (OPCIONALES porque no todas las armas los tienen)
@onready var muzzle_position: Marker2D = $MuzzlePosition if has_node("MuzzlePosition") else null
@onready var timer: Timer = $Timer if has_node("Timer") else null
# Propiedades comunes
@export var weapon_name: String = "Base Weapon"
@export var damage: int = 10
@export var fire_rate: float = 0.5
@export var weapon_type: WeaponType = WeaponType.RANGED

# Propiedades para armas de rango
@export var bullet_speed: float = 500.0
@export var max_ammo: int = 30
@export var current_ammo: int = 30
@export var reload_time: float = 2.0
@export var bullet_scene: PackedScene

# Estado
var can_shoot: bool = true
var is_reloading: bool = false

# Enum para tipos de arma
enum WeaponType {
	RANGED,   # Pistolas, rifles, etc.
	MELEE     # Espadas, hachas, etc.
}

func _ready() -> void:
	if timer:
		timer.wait_time = fire_rate
		timer.one_shot = true
		timer.timeout.connect(_on_timer_timeout)

func _process(delta: float) -> void:
	# Rotar hacia el mouse (común para todas las armas)
	look_at(get_global_mouse_position())
	# Voltear sprite (cada arma lo implementará a su manera)
	_flip_sprite()

# Función virtual para voltear sprite (cada arma la sobrescribe)
func _flip_sprite() -> void:
	# Las armas hijas sobrescribirán esto
	pass

# Función principal de ataque/disparo
func shoot() -> void:
	if not can_shoot or is_reloading:
		return
	
	if weapon_type == WeaponType.RANGED:
		_shoot_ranged()
	elif weapon_type == WeaponType.MELEE:
		_attack_melee()
	
	# Iniciar cooldown
	can_shoot = false
	timer.start()

# Función virtual para armas de rango
func _shoot_ranged() -> void:
	if current_ammo <= 0:
		return
	
	_spawn_bullet()
	current_ammo -= 1

# Función virtual para armas cuerpo a cuerpo
func _attack_melee() -> void:
	# Las armas cuerpo a cuerpo sobrescribirán esto
	pass

# Función para crear balas
func _spawn_bullet() -> void:
	if bullet_scene == null or muzzle_position == null:
		return
	
	var bullet = bullet_scene.instantiate()
	get_tree().root.add_child(bullet)
	bullet.global_position = muzzle_position.global_position
	bullet.rotation = rotation
	
	if bullet.has_method("initialize"):
		bullet.initialize(bullet_speed, damage)

# Recarga
func reload() -> void:
	if weapon_type != WeaponType.RANGED:
		return
	
	if is_reloading or current_ammo == max_ammo:
		return
	
	is_reloading = true
	await get_tree().create_timer(reload_time).timeout
	current_ammo = max_ammo
	is_reloading = false

func _on_timer_timeout() -> void:
	can_shoot = true
