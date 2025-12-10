extends Node2D

@export var damage = 0.5
@export var knockback = 50

func _on_attack_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		area.get_parent().take_damage(damage, global_position, knockback)
