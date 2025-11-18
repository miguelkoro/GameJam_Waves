extends CharacterBody2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite


func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	animate_player(input_dir)
	velocity = input_dir.normalized() * PlayerStats.agility
	move_and_slide()

func animate_player(input_dir:Vector2) ->void:
	if input_dir == Vector2.DOWN:
		animated_sprite.play("walk_south")
	else:
		animated_sprite.play("idle_south") 
	
