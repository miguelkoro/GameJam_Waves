extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var pause_menu: Control = $"."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("RESET")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func resume() -> void:
	get_tree().paused = false
	animation_player.play_backwards("blur")

func pause() -> void:
	get_tree().paused = true
	animation_player.play("blur")

func escPause() -> void:
	if Input.is_action_just_pressed("pause") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("pause") and get_tree().paused:
		resume()

func _on_resume_pressed() -> void:
	resume()

func _on_restart_pressed() -> void:
	resume()
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _process(_delta: float) -> void:
	escPause()
