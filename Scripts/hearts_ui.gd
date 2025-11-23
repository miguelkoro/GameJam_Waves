extends HBoxContainer

@export var heart_texture: Texture2D
@export var heart_size: Vector2i = Vector2i(16,16) #Tamaño de cada frame
@export var max_hearts: int = 5
var current_health: float = 3.5

func _ready() -> void:
	refresh_heart_nodes()
	update_hearts()	

func set_max_hearts(amount: int):	
	max_hearts = amount
	refresh_heart_nodes()
	update_hearts()
	
#func set_health(value:float):
#	current_health = clamp(value, 0, max_hearts)
#	update_hearts()
	
func update_hearts():
	print(PlayerStats.health)
	for i in range(PlayerStats.max_health):
		var heart_node := get_child(i) as TextureRect
		if not heart_node:
			continue

		# Cálculo del estado del corazón i
		var heart_value = PlayerStats.health - i
		var frame := 2 # vacío por defecto
		if heart_value >= 1:
			frame = 0 # lleno
		elif heart_value >= 0.5:
			frame = 1 # medio
		else:
			frame = 2 # vacío

		# Modificar la region del AtlasTexture
		var atlas := heart_node.texture as AtlasTexture
		atlas.atlas = heart_texture
		atlas.region = Rect2(frame * heart_size.x, 0, heart_size.x, heart_size.y)

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
