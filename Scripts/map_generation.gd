extends Node2D
@export var map_width: int = 120
@export var map_height: int = 63
@export var water_atlas_coords: Vector2i = Vector2i(1, 15)
@export var sand_atlas_coords: Vector2i = Vector2i(2, 7)
@export var rock_atlas_coords: Vector2i = Vector2i(3, 5)
@export var source_id: int = 0
@onready var tilemap = $TileMapLayer
@onready var agent_node = $Player
@export var num_islands = 7
@export var island_size = 17
@export var island_separation = 20  
@export var bridge_width = 2

var island_centers: Array = []

func _ready():
	generate_map()

func generate_map():
	tilemap.clear()
	island_centers.clear()
	generate_island_centers()
	var height_map = generate_islands()
	connect_islands(height_map)
	apply_tiles(height_map)

func generate_island_centers():
	var grid_cols = ceil(sqrt(num_islands * map_width / map_height))
	var grid_rows = ceil(float(num_islands) / grid_cols)
	
	var cell_width = map_width / grid_cols
	var cell_height = map_height / grid_rows
	
	for row in range(grid_rows):
		for col in range(grid_cols):
			if island_centers.size() >= num_islands:
				break
			
			var center_x = col * cell_width + cell_width / 2 + randf_range(-cell_width * 0.2, cell_width * 0.2)
			var center_y = row * cell_height + cell_height / 2 + randf_range(-cell_height * 0.2, cell_height * 0.2)
			island_centers.append(Vector2(center_x, center_y))

func generate_islands():
	var height_map = []
	height_map.resize(map_height)
	for i in range(map_height):
		height_map[i] = []
		height_map[i].resize(map_width)
		for j in range(map_width):
			height_map[i][j] = 0.0

	var base := FastNoiseLite.new()
	base.noise_type = FastNoiseLite.TYPE_PERLIN
	base.frequency = 0.015
	base.fractal_type = FastNoiseLite.FRACTAL_FBM
	base.fractal_octaves = 5
	base.seed = randi()
	
	var coast_noise := FastNoiseLite.new()
	coast_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	coast_noise.frequency = 0.05
	coast_noise.seed = randi()
	
	for y in range(map_height):
		for x in range(map_width):
			var pos = Vector2(x, y)
			var max_h = 0.0
			for center in island_centers:
				var nx = (x - center.x) / island_size
				var ny = (y - center.y) / island_size
				var d = sqrt(nx*nx + ny*ny)
				var h = (base.get_noise_2d(x, y) + 1.0) * 0.5
				var shape = (coast_noise.get_noise_2d(x * 2.0, y * 2.0) + 1.0) * 0.5
				shape = lerp(0.7, 1.3, shape)
				var falloff = pow(d * shape, 2.5)
				h -= falloff * 1.1
				max_h = max(max_h, h)
			height_map[y][x] = max_h
	return height_map

func connect_islands(height_map):
	var connected = {}
	
	for i in range(island_centers.size()):
		var closest_idx = -1
		var closest_dist = INF
		for j in range(island_centers.size()):
			if i == j:
				continue
			var pair_key = [mini(i, j), maxi(i, j)]
			if connected.has(pair_key):
				continue
			var dist = island_centers[i].distance_to(island_centers[j])
			if dist < closest_dist:
				closest_dist = dist
				closest_idx = j
		if closest_idx != -1:
			create_bridge(height_map, island_centers[i], island_centers[closest_idx])
			var pair_key = [mini(i, closest_idx), maxi(i, closest_idx)]
			connected[pair_key] = true

func create_bridge(height_map: Array, start: Vector2, end: Vector2):
	var distance = start.distance_to(end)
	var steps = int(distance * 2)
	
	for step in range(steps + 1):
		var t = float(step) / steps
		var point = start.lerp(end, t)
		
		for offset_x in range(-bridge_width, bridge_width + 1):
			for offset_y in range(-bridge_width, bridge_width + 1):
				var dist_from_center = sqrt(offset_x * offset_x + offset_y * offset_y)
				if dist_from_center > bridge_width:
					continue
				
				var x = int(point.x + offset_x)
				var y = int(point.y + offset_y)
				
				if x >= 0 and x < map_width and y >= 0 and y < map_height:
					var bridge_height = 0.2 + (1.0 - dist_from_center / bridge_width) * 0.15
					height_map[y][x] = max(height_map[y][x], bridge_height)
					
func apply_tiles(height_map: Array):
	for y in range(map_height):
		for x in range(map_width):
			var h = height_map[y][x]
			var tile_coords: Vector2i
			
			if h < 0.05:
				tile_coords = water_atlas_coords
				source_id = 4
			elif h < 0.25:
				tile_coords = rock_atlas_coords
				source_id = 1
			else:
				tile_coords = sand_atlas_coords
				source_id = 4
			
			tilemap.set_cell(Vector2i(x, y), source_id, tile_coords)

func pos_agent(pos):
	var world_pos = tilemap.map_to_local(pos)
	agent_node.global_position = world_pos
	agent_node.visible = true
	agent_node.scale = Vector2(0.5, 0.5)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		generate_map()
	if event is InputEventMouseButton and \
		event.pressed and \
		event.button_index == MOUSE_BUTTON_LEFT:
			var mouse_pos = get_global_mouse_position()
			var tile_pos = tilemap.local_to_map(mouse_pos)
			pos_agent(tile_pos)
