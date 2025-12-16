extends Weapon

@onready var weapon_sprite: Sprite2D = get_node_or_null("Sprite2D")

func _ready() -> void:
	super._ready()
	
	weapon_name = "Fusil"
	weapon_type = WeaponType.RANGED
	damage = 10
	fire_rate = 0.3
	bullet_speed = 600.0
	max_ammo = 100
	current_ammo = 12
	reload_time = 1.5
	bullet_scene = preload("res://Scenes/Bullets/bullet1.tscn")  
	
func _flip_sprite() -> void:
	if not weapon_sprite:
		return
	
	# Obtener posición del mouse y del jugador
	var mouse_pos = get_global_mouse_position()
	var player_pos = get_parent().get_parent().global_position  # Asumiendo WeaponPosition -> Player
	
	# Si el mouse está a la izquierda del jugador, girar
	if mouse_pos.x < player_pos.x:
		weapon_sprite.flip_v = true
	else:
		weapon_sprite.flip_v = false
