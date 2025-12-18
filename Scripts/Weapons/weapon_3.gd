extends Weapon
@onready var weapon_sprite: Sprite2D = $Sprite2D
@onready var flame_stream: FlameStream = $MuzzlePosition/FlameStream

var is_shooting: bool = false

func _ready() -> void:
	super._ready()
	
	weapon_name = "Lanzagatos"
	weapon_type = WeaponType.RANGED
	damage = 3
	fire_rate = 0.05 
	reload_time = 2.0
	max_total_ammo = 200
	total_ammo = 200
	magazine_size = 100
	ammo_in_mag = 100
	# Asegurar que la llama esté apagada al inicio
	if flame_stream:
		flame_stream.stop_flame()
		
	if audio_stream_player_2d:
		audio_stream_player_2d.finished.connect(_on_audio_finished)
	_get_data()
	
func _set_data() -> void:
	ammo_in_mag=100
	total_ammo=200

func _get_data() -> void:
	ammo_in_mag = PlayerStats.magacineAmmo		
	total_ammo = PlayerStats.totalAmmo     # Balas totales actuales

func _process(_delta: float) -> void:
	super._process(_delta)


#Sobrescribir el método shoot para comportamiento continuo
func shoot() -> void:
	#Si no puede disparar (recargando o sin munición), detener
	if is_reloading or ammo_in_mag <= 0:
		stop_shooting()
		if ammo_in_mag <= 0:
			empty.play()
		return
	
	#Si no estaba disparando, iniciar
	if not is_shooting:
		is_shooting = true
		if flame_stream:
			flame_stream.start_flame(damage)
		if audio_stream_player_2d and not audio_stream_player_2d.playing:
			audio_stream_player_2d.play()
	
	#Consumir munición continuamente
	if can_shoot:
		ammo_in_mag -= 1
		total_ammo -= 1
		emit_signal("ammo_changed", ammo_in_mag, total_ammo)
		
		can_shoot = false
		if timer:
			timer.start()

func stop_shooting() -> void:
	if is_shooting:
		is_shooting = false
		if flame_stream:
			flame_stream.stop_flame()
		if audio_stream_player_2d:
			audio_stream_player_2d.stop()

func _flip_sprite() -> void:
	if not weapon_sprite:
		return
	var mouse_pos = get_global_mouse_position()
	var player_pos = get_parent().get_parent().global_position
	weapon_sprite.flip_v = mouse_pos.x < player_pos.x

#Sobrescribir reload para detener disparo
func reload() -> void:
	stop_shooting()
	super.reload()

func _on_audio_finished() -> void:
	#Solo repetir si está disparando
	if is_shooting and audio_stream_player_2d:
		audio_stream_player_2d.play()
