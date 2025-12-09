extends Node2D
@onready var audio_Seagull: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var panel: Panel = $Panel
var player_is_near: bool = false
@onready var canvas_layer: CanvasLayer = $CanvasLayer
var player = null
var gui = null

func _ready() -> void:
	gui = get_tree().get_first_node_in_group("HeartsUI")

func _process(delta: float) -> void:
	if not player_is_near:
		return
	if Input.is_action_just_pressed("ui_accept"):
		if not audio_Seagull.playing:
			audio_Seagull.play()
		#Aqui poner lo de abrir el menu de la tienda
		print("Abrir tienda")
		canvas_layer.visible = true
		if player != null:
			player.inactive = true

		gui.visible = false
		


func _on_show_label_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		panel.visible = true
		player = body
		player_is_near = true
		
		


func _on_show_label_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		panel.visible = false
		player = null
		player_is_near = false


func _on_back_button_pressed() -> void:
	player.inactive = false
	canvas_layer.visible = false
	gui.visible = true
