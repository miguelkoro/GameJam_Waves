extends Node2D
@onready var audio_boat: AudioStreamPlayer2D = $AudioStreamPlayer_Boat
@onready var panel: Panel = $Panel
var player_is_near: bool = false


func _process(delta: float) -> void:
	if not player_is_near:
		return
	if Input.is_action_just_pressed("ui_accept"):
		if not audio_boat.playing:
			audio_boat.play()
		#Aqui generar el mapa y el efecto de viajar ¿?
		print("Nueva run")
		get_tree().change_scene_to_file("res://Scenes/Rooms/room.tscn")
		pass

func _on_show_label_body_entered(body: Node2D) -> void:

	if body.is_in_group("Player"):
		panel.visible = true
		player_is_near = true
		


func _on_show_label_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		panel.visible = false
		player_is_near = false
		
