extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred("_go_to_menu")

func _go_to_menu() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")
