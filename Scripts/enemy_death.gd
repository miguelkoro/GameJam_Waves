extends Node2D


func _on_animated_sprite_enemy_death_animation_finished() -> void:
	queue_free()
