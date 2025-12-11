extends Node2D

@export var pearl_amount: int = 1
@export var pearl_spawn_prob: float = 0.2
const AUDIO_STREAM_PLAYER_PICK_ITEM = preload("uid://bkojkgnvtpjx0")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		GameManager.add_currency(pearl_amount)
		var t = create_tween()
		t.tween_property(self, "scale", Vector2(1.5,1.5), 0.1)
		t.tween_property(self, "modulate:a", 0.0, 0.1)
		await t.finished
		
				#Crear audio que se desruye al sonar
		var audio = AUDIO_STREAM_PLAYER_PICK_ITEM.instantiate()
		audio.position = self.position
		get_parent().add_child(audio)
		audio.play()
		await get_tree().create_timer(audio.stream.get_length()).timeout
		audio.queue_free()
		queue_free()
		
		
		queue_free()
