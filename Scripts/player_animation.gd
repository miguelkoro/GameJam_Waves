extends Node2D

@export var animation_tree: AnimationTree
@onready var player: Node2D = get_owner()
var last_facing_direction := Vector2(0,0)

func _physics_process(delta: float) -> void:
	var idle = !player.velocity
	if !idle:
		last_facing_direction = player.velocity.normalized()
		
	animation_tree.set("parameters/conditions/run", idle)
	animation_tree.set("parameters/conditions/idle", !idle)
	
	animation_tree.set("parameters/Idle/blend_position", last_facing_direction)
	animation_tree.set("parameters/Run/blend_position", last_facing_direction)
