extends Camera2D

@onready var map = $"../.."
var tile_size = 16  

func _ready():
	limit_left = 0
	limit_top = 0
	limit_right = map.map_width * tile_size
	limit_bottom = map.map_height * tile_size
