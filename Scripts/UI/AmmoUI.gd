extends MarginContainer
@onready var ammo_label: Label = $HBoxContainer/AmmoLabel
@onready var reload_panel: Panel = $ReloadPane
@onready var reload_label: Label = $ReloadPane/ReloadLabel

var current_weapon: Weapon = null

func _ready() -> void:
	if reload_panel:
		reload_panel.visible = false

	call_deferred("_find_player")

func _find_player():
	# Buscar al jugador en el árbol
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		# Aquí conectaremos las señales cuando las añadamos
		pass

func _process(_delta: float) -> void:
	_update_ammo_display()

func _update_ammo_display():
	# Obtener el arma actual del jugador
	var player = get_tree().get_first_node_in_group("Player")
	if not player or not player.current_weapon:
		ammo_label.text = ""
		return
	
	current_weapon = player.current_weapon
	
	# Mostrar munición solo para armas de rango
	if current_weapon.weapon_type == Weapon.WeaponType.RANGED:
		if current_weapon.is_reloading:
			ammo_label.text = "Recargando..."
			show_reload_message(false)  # Ocultar el mensaje de "Pulsa R"
		else:
			ammo_label.text = str(current_weapon.current_ammo) + " / " + str(current_weapon.max_ammo)
			
			# Mostrar mensaje de recarga si no hay munición
			if current_weapon.current_ammo == 0:
				show_reload_message(true)
			else:
				show_reload_message(false)
	else:
		# Para armas cuerpo a cuerpo no mostrar munición
		ammo_label.text = ""
		show_reload_message(false)

func show_reload_message(show: bool):
	if reload_panel:
		reload_panel.visible = show
		
		# Animación parpadeante opcional
		if show and not reload_panel.has_meta("tween_running"):
			_start_blink_animation()
		elif not show and reload_panel.has_meta("tween_running"):
			_stop_blink_animation()

func _start_blink_animation():
	reload_panel.set_meta("tween_running", true)
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(reload_label, "modulate:a", 0.3, 0.5)
	tween.tween_property(reload_label, "modulate:a", 1.0, 0.5)

func _stop_blink_animation():
	reload_panel.remove_meta("tween_running")
	# Detener cualquier tween activo en reload_label
	var tweens = reload_label.get_tree().get_processed_tweens()
	for tween in tweens:
		tween.kill()
	reload_label.modulate.a = 1.0
