extends Node2D
@onready var audio_Seagull: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var panel: Panel = $Panel
var player_is_near: bool = false
@onready var canvas_layer: CanvasLayer = $CanvasLayer
var player = null
var gui = null
@onready var label: Label = $CanvasLayer/Control/PearlsUI/Label

@export var weapon_1_scene: PackedScene
@export var weapon_2_scene: PackedScene
@export var weapon_3_scene: PackedScene
@export var weapon_4_scene: PackedScene
@onready var warning: Label = $CanvasLayer/Control/warning

func _ready() -> void:
	gui = get_tree().get_first_node_in_group("GUI")

func _process(delta: float) -> void:
	if not player_is_near:
		return
	if Input.is_action_just_pressed("ui_accept"):
		if not audio_Seagull.playing:
			audio_Seagull.play()
		#Aqui poner lo de abrir el menu de la tienda
		open_shop()
		
func open_shop() -> void:
	print("Abrir tienda")
	canvas_layer.visible = true
	if player != null:
		player.inactive = true
		gui = get_tree().get_first_node_in_group("GUI")
		gui.visible = false
	label.text = "X " + str(GameManager.currency)

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
	
func buy_weapon(weapon_scene: PackedScene, price: int) -> void:
	if GameManager.currency < price:
		print("No tienes suficientes perlas")
		warning.visible = true
		await get_tree().create_timer(1.0).timeout
		warning.visible = false
		return
	GameManager.remove_currency(price)
	player.equip_weapon(weapon_scene)
	PlayerStats.current_weapon = weapon_scene
	player.inactive = false
	canvas_layer.visible = false
	gui.visible = true
	
func _on_button1_pressed() -> void:
	buy_weapon(weapon_1_scene, 25)
	
func _on_button2_pressed() -> void:
	buy_weapon(weapon_2_scene, 20)

func _on_button3_pressed() -> void:
	buy_weapon(weapon_3_scene, 23)
	
func _on_button4_pressed() -> void:
	buy_weapon(weapon_4_scene, 18)
