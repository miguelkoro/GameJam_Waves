extends Control

@onready var main_buttons: VBoxContainer = $MainButtons
@onready var controls: Panel = $Controls
@onready var title: Label = $Title

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_buttons.visible = true
	title.visible = true
	controls.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_start_game_pressed() -> void:
	print("Start Game pressed")
	get_tree().change_scene_to_file("res://Scenes/test.tscn") # Replace with function body.


func _on_controls_pressed() -> void:
	print("Controls pressed")
	main_buttons.visible = false
	title.visible = false
	controls.visible = true


func _on_exit_pressed() -> void:
	print("Exit pressed")
	get_tree().quit() # Replace with function body.


func _on_back_pressed() -> void:
	print("Back pressed")
	_ready()
	
