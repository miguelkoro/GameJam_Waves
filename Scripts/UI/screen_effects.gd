extends CanvasLayer
@onready var rect_ink_effect: ColorRect = $ColorRect_inkEffect
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var color_rect_ink_effect: ColorRect = $ColorRect_inkEffect

func _ink_effect() -> void:
	animation_player.play("ink_effect")
	var mat := color_rect_ink_effect.material as ShaderMaterial
	if mat == null:
		return

	# Activamos
	mat.set_shader_parameter("intensity", 1.0)
	# Fade out suave
	var tween := get_tree().create_tween()
	tween.tween_property(mat, "shader_parameter/intensity", 0.0, 1.1)
