extends Control

#@onready var main_buttons: VBoxContainer = $MainButtons
@onready var controls: Panel = $Controls
@onready var title: Label = $Title
@onready var controls_button: MarginContainer = $ControlsButton
@onready var exit_button: MarginContainer = $ExitButton
@onready var start_button: MarginContainer = $StartButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#main_buttons.visible = true
	exit_button.visible = true
	start_button.visible = true
	title.visible = true
	controls.visible = false
	controls_button.visible = true

func _on_start_game_pressed() -> void:
	print("Start Game pressed")
	get_tree().change_scene_to_file("res://Scenes/Town/Town.tscn") # Replace with function body.

func _on_back_pressed() -> void:
	print("Back pressed")
	_ready()
	
func _on_controls_button_pressed() -> void:
	print("Controls pressed")
	#main_buttons.visible = false
	title.visible = false
	controls_button.visible = false
	controls.visible = true
	exit_button.visible = false
	start_button.visible = false


func _on_exit_button_pressed() -> void:
	print("Exit pressed")
	get_tree().quit() # Replace with function body.
