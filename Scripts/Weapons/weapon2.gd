extends Weapon

@onready var weapon_sprite: Sprite2D = get_node_or_null("Sprite2D")

func _ready() -> void:
	super._ready()
	
	weapon_name = "Pistola Láser"
	weapon_type = WeaponType.RANGED
	damage = 5
	fire_rate = 0.5
	bullet_speed = 800.0
	max_total_ammo=60
	total_ammo=60
	magazine_size=10
	ammo_in_mag=10
	reload_time = 0.1
	bullet_scene = preload("res://Scenes/Bullets/bullet2.tscn")  
	_get_data()
	
func _set_data() -> void:
	ammo_in_mag=10
	total_ammo=60

func _get_data() -> void:
	ammo_in_mag = PlayerStats.magacineAmmo		
	total_ammo = PlayerStats.totalAmmo     # Balas totales actuales

func _flip_sprite() -> void:
	if not weapon_sprite:
		return
	
	var mouse_pos = get_global_mouse_position()
	var player_pos = get_parent().get_parent().global_position  
	
	if mouse_pos.x < player_pos.x:
		weapon_sprite.flip_v = true
	else:
		weapon_sprite.flip_v = false
