extends Node2D

@export var heal_amount: float = 1.0

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		PlayerStats.healing(heal_amount)
		var t = create_tween()
		t.tween_property(self, "scale", Vector2(1.5,1.5), 0.1)
		t.tween_property(self, "modulate:a", 0.0, 0.1)
		await t.finished
		queue_free()
