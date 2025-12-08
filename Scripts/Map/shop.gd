extends Node2D
@onready var audio_Seagull: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var panel: Panel = $Panel
var player_is_near: bool = false

func _process(delta: float) -> void:
	if not player_is_near:
		return
	if Input.is_action_just_pressed("ui_accept"):
		if not audio_Seagull.playing:
			audio_Seagull.play()
		#Aqui poner lo de abrir el menu de la tienda
		print("Abrir tienda")
		pass


func _on_show_label_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		panel.visible = true
		player_is_near = true
		


func _on_show_label_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		panel.visible = false
		player_is_near = false
