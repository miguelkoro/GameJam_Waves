extends Node2D
@onready var audio_boat: AudioStreamPlayer2D = $AudioStreamPlayer_Boat
@onready var panel: Panel = $Panel
var player_is_near: bool = false
@onready var animation_player_fade_in_out: AnimationPlayer = $AnimationPlayer_FadeIn_Out

@export var toNewRun:bool = true #Si es true va hacia una nueva room, si es false va hacia el pueblo

func _process(delta: float) -> void:
	if not player_is_near:
		return
	if Input.is_action_just_pressed("ui_accept"):
		if not audio_boat.playing:
			audio_boat.play()
		#Aqui generar el mapa y el efecto de viajar ¿?
		#print("Nueva run")
		animation_player_fade_in_out.play("Fade_Out")
		pass

func _on_show_label_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		panel.visible = true
		player_is_near = true
		


func _on_show_label_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		panel.visible = false
		player_is_near = false

		
		
func _travel_new_run()->void:
	get_tree().change_scene_to_file("res://Scenes/Game/Run.tscn")


func _on_animation_player_fade_in_out_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Fade_Out":
		if toNewRun:
			_travel_new_run()
		else:
			get_tree().change_scene_to_file("res://Scenes/Town/Town.tscn")
