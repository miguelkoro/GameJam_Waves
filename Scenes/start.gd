extends Node2D
@onready var player = $Player
@onready var shop = $TiendaPlaya
@onready var ship = $Barcos
@export var interaction_distance: float = 150.0
var shop_ui: CanvasLayer = null
var near_shop: bool = false
var near_boat: bool = false
var weapons = [
	{"name": "Weapon1", "price": 0, "damage": 0},
	{"name": "Weapon2", "price": 0, "damage": 0}
]

func _ready():
	create_shop_ui()

func _process(_delta):
	check_proximity()

func check_proximity():
	var player_pos = player.global_position
	var dist_to_shop = player_pos.distance_to(shop.global_position)
	near_shop = dist_to_shop < interaction_distance
	
	var dist_to_boat = player_pos.distance_to(ship.global_position)
	near_boat = dist_to_boat < interaction_distance

func _input(event):
	if event.is_action_pressed("ui_accept"):
		if near_shop:
			toggle_shop()
	
	if event is InputEventKey and event.pressed and event.keycode == KEY_ENTER:
		if near_boat:
			get_tree().change_scene_to_file("res://Scenes/test.tscn")

func create_shop_ui():
	shop_ui = CanvasLayer.new()
	shop_ui.name = "ShopUI"
	shop_ui.process_mode = Node.PROCESS_MODE_ALWAYS  
	add_child(shop_ui)
	
	var control = Control.new()
	control.set_anchors_preset(Control.PRESET_FULL_RECT)
	shop_ui.add_child(control)
	
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.7)  
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	control.add_child(bg)
	
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(800, 900)
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -400 
	panel.offset_top = -450   
	panel.offset_right = 400
	panel.offset_bottom = 450
	control.add_child(panel)
	
	var title = Label.new()
	title.text = "Weapon Store"
	title.position = Vector2(270, 30)
	title.add_theme_font_size_override("font_size", 32)
	panel.add_child(title)
	
	var close_btn = Button.new()
	close_btn.text = "X"
	close_btn.position = Vector2(740, 15)
	close_btn.custom_minimum_size = Vector2(45, 45)
	close_btn.add_theme_font_size_override("font_size", 24)
	close_btn.process_mode = Node.PROCESS_MODE_ALWAYS
	close_btn.pressed.connect(_on_close_pressed)
	panel.add_child(close_btn)
	
	for i in range(weapons.size()):
		create_weapon_item(panel, weapons[i], i)
	
	shop_ui.visible = false

func create_weapon_item(parent: Panel, weapon: Dictionary, index: int):
	var y_offset = 100 + (index * 180)
	
	var item_panel = Panel.new()
	item_panel.custom_minimum_size = Vector2(740, 150)
	item_panel.position = Vector2(30, y_offset)
	parent.add_child(item_panel)
	
	var name_label = Label.new()
	name_label.text = weapon.name
	name_label.position = Vector2(20, 20)
	name_label.add_theme_font_size_override("font_size", 28)
	item_panel.add_child(name_label)
	
	var price_label = Label.new()
	price_label.text = "Price: " + str(weapon.price) + " pearl"
	price_label.position = Vector2(20, 65)
	price_label.add_theme_font_size_override("font_size", 20)
	item_panel.add_child(price_label)
	
	var damage_label = Label.new()
	damage_label.text = "Damage: " + str(weapon.damage)
	damage_label.position = Vector2(20, 100)
	damage_label.add_theme_font_size_override("font_size", 20)
	item_panel.add_child(damage_label)
	
	var buy_btn = Button.new()
	buy_btn.text = "BUY"
	buy_btn.position = Vector2(550, 40)
	buy_btn.custom_minimum_size = Vector2(160, 70)
	buy_btn.add_theme_font_size_override("font_size", 22)
	buy_btn.process_mode = Node.PROCESS_MODE_ALWAYS
	item_panel.add_child(buy_btn)

func _on_close_pressed():
	toggle_shop()

func toggle_shop():
	if shop_ui:
		shop_ui.visible = !shop_ui.visible
		get_tree().paused = shop_ui.visible
