extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var buttons_container = $Panel/VBoxContainer

func _ready() -> void:
	# El menú existe, pero NO interactúa
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_NONE

	_set_buttons_enabled(false)
	animation_player.play("RESET")


# ─────────────────────────────
# INPUT (solo pausa)
# ─────────────────────────────
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if get_tree().paused:
			resume()
		else:
			pause()


# ─────────────────────────────
# PAUSE / RESUME
# ─────────────────────────────
func pause() -> void:
	get_tree().paused = true

	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL
	_set_buttons_enabled(true)

	animation_player.play("blur")

	# Foco explícito al primer botón
	if buttons_container.get_child_count() > 0:
		buttons_container.get_child(0).grab_focus()


func resume() -> void:
	get_tree().paused = false

	animation_player.play_backwards("blur")
	await animation_player.animation_finished

	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_NONE
	_set_buttons_enabled(false)


# ─────────────────────────────
# BOTONES
# ─────────────────────────────
func _on_resume_pressed() -> void:
	resume()

func _on_restart_pressed() -> void:
	resume()
	get_tree().reload_current_scene()
	GameManager.restart()
	PlayerStats.restart()

func _on_quit_pressed() -> void:
	get_tree().quit()


# ─────────────────────────────
# UTILIDADES
# ─────────────────────────────
func _set_buttons_enabled(enabled: bool) -> void:
	for child in buttons_container.get_children():
		if child is Button:
			child.disabled = not enabled


# ─────────────────────────────
# BLINDAJE EXTRA (opcional pero recomendado)
# Evita cualquier input UI cuando está oculto
# ─────────────────────────────
func _gui_input(event: InputEvent) -> void:
	if not visible:
		event.consume()
