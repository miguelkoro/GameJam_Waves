extends Node2D
#@onready var panel: Panel = $Panel
var player_is_near: bool = false
@onready var label_charm: Label = $Panel_charm/Label_charm
@export var donateAmount: int = 3
@onready var panel: Node2D = $donate_panel
@onready var sprite_2d: Sprite2D = $Sprite2D
var desactivated: bool = false
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and not desactivated:
		panel.visible = true
		player_is_near = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player") and not desactivated:
		panel.visible = false
		player_is_near = false
		
func _donate() -> void:
	if GameManager.currency >= donateAmount:
		if GameManager.remove_currency(donateAmount):
			var rand = randi_range(0,1)
			desactivated = true
			panel.visible = false
			match rand:
				0:
					_more_drops()
				1:
					_more_enemies()
		
func _more_enemies() -> void:
	GameManager.enemiesMulti = 1.5	
	label_charm.text = "MORE ENEMIES"
	sprite_2d.frame = 0
	animation_player.play("more_enemies")

	
func _more_drops() -> void:
	GameManager.dropMulti = 1.5
	label_charm.text = "MORE DROPS"
	sprite_2d.frame = 1
	animation_player.play("more_drops")


	

func _process(delta: float) -> void:
	if not player_is_near:
		return
	if Input.is_action_just_pressed("ui_accept"):
		_donate()
		
