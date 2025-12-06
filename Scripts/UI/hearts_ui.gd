extends HBoxContainer

@export var heart_texture: Texture2D
@export var heart_size: Vector2i = Vector2i(16,16) #Tamaño de cada frame


func _ready() -> void:
	refresh_heart_nodes()
	update_hearts(PlayerStats.last_health, PlayerStats.health)	

func update_hearts(last_health: float, health: float):
	var lost = health < last_health
	var gained = health > last_health

	for i in range(PlayerStats.max_health):
		var heart := get_child(i) as TextureRect
		if not heart:
			continue

		var old_value = last_health - i
		var new_value = health - i

		# --- Determinar frame ---
		var frame := 2  # vacío
		if new_value >= 1:
			frame = 0  # lleno
		elif new_value >= 0.5:
			frame = 1  # medio

		# --- Actualizar atlas ---
		var atlas := heart.texture as AtlasTexture
		# IMPORTANTE: reasignar atlas texture (a veces si no lo haces no refresca)
		atlas.atlas = heart_texture
		atlas.region = Rect2(frame * heart_size.x, 0, heart_size.x, heart_size.y)

		# --- Detectar y animar cambio ---
		if lost:
			if old_value > new_value:
				shake_heart(heart)
		elif gained:
			if new_value > old_value:
				heal_pop(heart)



func refresh_heart_nodes():
	# Eliminar hearts de más
	while get_child_count() > PlayerStats.max_health:
		get_child(get_child_count() - 1).queue_free()

	# Crear los que faltan
	while get_child_count() < PlayerStats.max_health:
		var tex := AtlasTexture.new()
		tex.atlas = heart_texture
		tex.region = Rect2(0, 0, heart_size.x, heart_size.y)

		var trect := TextureRect.new()
		trect.texture = tex
		trect.custom_minimum_size = heart_size
		trect.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		add_child(trect)
#Pequeña sacudida al perder vida		
func shake_heart(heart: TextureRect):
	var t = create_tween()
	var original_scale = heart.scale
	# Pequeño pop (escala un poco)
	t.tween_property(heart, "scale", original_scale * 1.2, 0.06)
	t.tween_property(heart, "scale", original_scale * 0.9, 0.06)
	t.tween_property(heart, "scale", original_scale, 0.06)
	# Vibración leve después
	var original_pos := heart.position
	t.tween_property(heart, "position", original_pos + Vector2(0, -2), 0.03)
	t.tween_property(heart, "position", original_pos, 0.03)
#Animacion de curarse
func heal_pop(heart: TextureRect):
	var t = create_tween()
	var original_scale = heart.scale

	t.tween_property(heart, "scale", original_scale * 1.15, 0.12)
	t.tween_property(heart, "scale", original_scale, 0.12)
