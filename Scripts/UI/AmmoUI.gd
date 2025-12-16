extends MarginContainer

@onready var ammo_label: Label = $HBoxContainer/AmmoLabel
@onready var reload_panel: Panel = $ReloadPane
@onready var reload_label: Label = $ReloadPane/ReloadLabel

var current_weapon: Weapon = null
var player: Node = null

func _ready() -> void:
	if reload_panel:
		reload_panel.visible = false

	call_deferred("_find_player")

func _find_player() -> void:
	player = get_tree().get_first_node_in_group("Player")

func _process(_delta: float) -> void:
	_update_ammo_display()

func _update_ammo_display() -> void:
	if not player or not player.current_weapon:
		ammo_label.text = ""
		show_reload_message(false)
		return

	current_weapon = player.current_weapon

	# Solo mostrar munición para armas a distancia
	if current_weapon.weapon_type == Weapon.WeaponType.RANGED:
		
		# Texto cargador / total
		ammo_label.text = str(current_weapon.ammo_in_mag) + " / " + str(current_weapon.total_ammo)

		# Mostrar aviso de recarga
		if current_weapon.is_reloading:
			show_reload_message(false)
		elif current_weapon.ammo_in_mag == 0 and current_weapon.total_ammo > 0:
			show_reload_message(true)
		else:
			show_reload_message(false)
	else:
		ammo_label.text = ""
		show_reload_message(false)

@warning_ignore("shadowed_variable_base_class")
func show_reload_message(show: bool) -> void:
	if not reload_panel:
		return

	reload_panel.visible = show

	if show and not reload_panel.has_meta("tween_running"):
		_start_blink_animation()
	elif not show and reload_panel.has_meta("tween_running"):
		_stop_blink_animation()

func _start_blink_animation() -> void:
	reload_panel.set_meta("tween_running", true)
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(reload_label, "modulate:a", 0.3, 0.5)
	tween.tween_property(reload_label, "modulate:a", 1.0, 0.5)

func _stop_blink_animation() -> void:
	if reload_panel.has_meta("tween_running"):
		reload_panel.remove_meta("tween_running")

	var tweens = reload_label.get_tree().get_processed_tweens()
	for tween in tweens:
		tween.kill()

	reload_label.modulate.a = 1.0
