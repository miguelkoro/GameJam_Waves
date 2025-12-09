extends Weapon

@onready var weapon_sprite: Sprite2D = get_node_or_null("Sprite2D")

func _ready() -> void:
	super._ready()
	
	weapon_name = "Pistola Láser"
	weapon_type = WeaponType.RANGED
	damage = 20
	fire_rate = 0.5
	bullet_speed = 800.0
	max_ammo = 80
	current_ammo = 10
	reload_time = 0.1
	bullet_scene = preload("res://Scenes/Bullets/bullet2.tscn")  
