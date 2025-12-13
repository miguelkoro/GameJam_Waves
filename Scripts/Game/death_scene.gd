extends Node2D


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	
	if anim_name == "Player_Death":
		#LE quitamos dinero 20% o asi
		GameManager.death_currency()
		get_tree().change_scene_to_file("res://Scenes/Town/Town.tscn") #Volvemos al pueblo
