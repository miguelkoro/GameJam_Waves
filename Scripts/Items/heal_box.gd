extends StaticBody2D

@export var heal_amount: float = 0.5
@onready var panel: Panel = $Panel
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer_heal: Timer = $Timer_Heal

var player_in_range: bool = false #Si el jugador esta cerca
var healing: bool = false #Si esta curando
var player: Node2D = null

#func _on_body_entered(body: Node2D) -> void:
#	if body.is_in_group("Player"):
#		body.healing(heal_amount)
func _ready() -> void:
	timer_heal.connect("timeout", Callable(self, "_on_heal_tick"))
		
func _process(delta: float) -> void:
	if not healing:
		if not player_in_range:
			return
		#Activar curacion y meter al jugador en la caja
		if Input.is_action_just_pressed("ui_accept"):
			start_healing()
	else:
		if Input.is_action_just_pressed("ui_accept"):
			stop_healing()
		

func start_healing() ->void:
	if player == null:
		return
	healing = true
	animated_sprite.play("full")
	player.visible = false
	timer_heal.start()
	panel.visible = false

func stop_healing() -> void:
	healing = false
	timer_heal.stop()
	player.visible = true
	animated_sprite.play("idle")
	panel.visible = true

func _on_heal_tick() -> void:
	if player and healing:
		player.healing(heal_amount)


func _on_show_label_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = true
		panel.visible = true
		player = body
		

func _on_show_label_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = false
		panel.visible = false
		player = null
		
