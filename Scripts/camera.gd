extends Camera2D

@export var smoothing_speed: float = 4.0
@onready var player: Node2D = $"../YSort/Player"
@onready var tilemap: TileMapLayer = $"../TileMapLayer"

var map_min := Vector2.ZERO
var map_max := Vector2.ZERO


func _ready():
	# Obtener rectángulo usado del tilemap en celdas
	var rect: Rect2i = tilemap.get_used_rect()
	var tile_size: Vector2i = tilemap.tile_set.tile_size

	# Convertir a coordenadas globales
	map_min = rect.position * tile_size
	map_max = (rect.position + rect.size) * tile_size

	# Activa smoothing interno de Camera2D (pero lo refinamos a mano)
	position_smoothing_enabled = false


func _physics_process(delta: float) -> void:
	if not player:
		return

	# Dimensiones de lo que la cámara puede ver
	var half_view: Vector2 = get_viewport().get_visible_rect().size * 0.5 / zoom

	# Posición objetivo basada en el jugador
	var target_position: Vector2 = player.global_position

	# Limitar cámara dentro de los límites del mapa
	target_position.x = clamp(target_position.x, map_min.x + half_view.x, map_max.x - half_view.x)
	target_position.y = clamp(target_position.y, map_min.y + half_view.y, map_max.y - half_view.y)

	# Movimiento suavizado
	global_position = global_position.lerp(target_position, smoothing_speed * delta)
