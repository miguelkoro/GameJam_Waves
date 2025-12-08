extends Node2D

@export var animation_tree: AnimationTree
@onready var player: Node2D = get_owner()
var last_facing_direction := Vector2(0,0)

func _physics_process(delta: float) -> void:
	var anim_dir = player.direction  # ← viene de player.gd

	animation_tree.set("parameters/PlayerStates/Idle/blend_position", anim_dir)
	animation_tree.set("parameters/PlayerStates/Run/blend_position", anim_dir)
	animation_tree.set("parameters/PlayerStates/Attack/blend_position", anim_dir)
	animation_tree.set("parameters/PlayerStates/Shoot/blend_position", anim_dir)

	animation_tree.set("parameters/TimeScale/scale", 1.0)
