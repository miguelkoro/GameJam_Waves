extends Node2D

@export var heal_amount: float = 1.0
const AUDIO_STREAM_PLAYER_EAT = preload("uid://bkojkgnvtpjx0")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.healing(heal_amount)
		var t = create_tween()
		t.tween_property(self, "scale", Vector2(1.5,1.5), 0.1)
		t.tween_property(self, "modulate:a", 0.0, 0.1)
		await t.finished
		#Crear audio que se desruye al sonar
		var audio = AUDIO_STREAM_PLAYER_EAT.instantiate()
		audio.position = self.position
		get_parent().add_child(audio)
		audio.play()
		await get_tree().create_timer(audio.stream.get_length()).timeout
		audio.queue_free()
		queue_free()
