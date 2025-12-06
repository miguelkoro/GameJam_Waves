extends Node2D

@export var pearl_amount: int = 1

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		GameManager.add_currency(pearl_amount)
		var t = create_tween()
		t.tween_property(self, "scale", Vector2(1.5,1.5), 0.1)
		t.tween_property(self, "modulate:a", 0.0, 0.1)
		await t.finished
		queue_free()
