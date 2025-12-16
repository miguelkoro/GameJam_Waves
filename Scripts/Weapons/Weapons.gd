extends Node2D
class_name Weapon

@onready var muzzle_position: Marker2D = $MuzzlePosition if has_node("MuzzlePosition") else null
@onready var timer: Timer = $Timer if has_node("Timer") else null
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D if has_node("AudioStreamPlayer2D") else null
@export var weapon_name: String = "Base Weapon"
@export var damage: int = 10
@export var fire_rate: float = 0.5
@export var weapon_type: WeaponType = WeaponType.RANGED
@onready var empty: AudioStreamPlayer2D = $empty


@export var bullet_speed: float = 500.0
@export var max_total_ammo: int = 100   # Máximo de balas totales (reserva)
@export var total_ammo: int = 100       # Balas totales actuales
@export var magazine_size: int = 12     # Tamaño del cargador
@export var ammo_in_mag: int = 12       # Balas actuales en el cargador
@export var reload_time: float = 2.0
@export var bullet_scene: PackedScene
@onready var gun_reload: AudioStreamPlayer2D = $gun_reload

var can_shoot: bool = true
var is_reloading: bool = false
enum WeaponType {
	RANGED,
	MELEE
}

signal ammo_changed(ammo_in_mag: int, total_ammo: int)
signal reload_started()
signal reload_finished()
signal out_of_ammo()

func _ready() -> void:
	if timer:
		timer.wait_time = fire_rate
		timer.one_shot = true
		timer.timeout.connect(_on_timer_timeout)

	total_ammo = min(total_ammo, max_total_ammo)
	ammo_in_mag = min(ammo_in_mag, magazine_size)

	emit_signal("ammo_changed", ammo_in_mag, total_ammo)

func _process(delta: float) -> void:
	look_at(get_global_mouse_position())
	_flip_sprite()

func _flip_sprite() -> void:
	pass
	
#Disparo
func shoot() -> void:
	if not can_shoot or is_reloading:
		return
	if weapon_type == WeaponType.RANGED:
		_shoot_ranged()
	elif weapon_type == WeaponType.MELEE:
		_attack_melee()

	# Solo suena si hay balas (RANGED) o es MELEE
	if audio_stream_player_2d and (weapon_type == WeaponType.MELEE or ammo_in_mag > 0):
		audio_stream_player_2d.play()
	else:
		empty.play()

	can_shoot = false
	if timer:
		timer.start()

func _shoot_ranged() -> void:
	if ammo_in_mag <= 0:
		emit_signal("out_of_ammo")
		return
	_spawn_bullet()
	ammo_in_mag -= 1
	total_ammo -= 1
	emit_signal("ammo_changed", ammo_in_mag, total_ammo)

func _attack_melee() -> void:
	pass

func _spawn_bullet() -> void:
	if bullet_scene == null or muzzle_position == null:
		return

	var bullet = bullet_scene.instantiate()
	get_tree().root.add_child(bullet)
	bullet.global_position = muzzle_position.global_position
	bullet.rotation = rotation
	if bullet.has_method("initialize"):
		bullet.initialize(bullet_speed, damage)

#Recarga
func reload() -> void:
	if weapon_type != WeaponType.RANGED:
		return
	if is_reloading:
		return
	# No recargar si no hace falta o no hay balas
	if ammo_in_mag == magazine_size or total_ammo <= 0:
		return
	is_reloading = true
	emit_signal("reload_started")
	gun_reload.play()
	await get_tree().create_timer(reload_time).timeout
	var missing = magazine_size - ammo_in_mag
	var ammo_to_load = min(missing, total_ammo)
	ammo_in_mag += ammo_to_load
	is_reloading = false
	emit_signal("reload_finished")
	emit_signal("ammo_changed", ammo_in_mag, total_ammo)

#Timer
func _on_timer_timeout() -> void:
	can_shoot = true

# MÉTODOS AUXILIARES.
func add_ammo(amount: int) -> void:
	total_ammo = min(total_ammo + amount, max_total_ammo)
	emit_signal("ammo_changed", ammo_in_mag, total_ammo)

func set_initial_ammo(total: int, mag: int) -> void:
	total_ammo = min(total, max_total_ammo)
	ammo_in_mag = min(mag, magazine_size)
	emit_signal("ammo_changed", ammo_in_mag, total_ammo)
