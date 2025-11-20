extends CharacterBody2D
var direction: Vector2 = Vector2.ZERO
var attacking: bool = false


func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = input_dir.normalized() * PlayerStats.agility
	move_and_slide()
