extends Node2D

@export var arrayObstacles: Array[PackedScene] #Corrientes de agua, paredes, agujeros... tamaño variable
@export var arrayRocks: Array[PackedScene] # de tamaño 1x1
@export var arrayEnemies: Array[PackedScene] #Enemigos de tipo medusa o cangrejo hermitaño #Tamaño 1x1
@export var noise: FastNoiseLite
const TILE_SIZE: int = 32 #Pixeles de cada tile 32x32
@export var height: int = 18 #Altura de la sala
@export var width: int = 29 #Ancho de la sala
@export var sc: float = 0.1 #Noise scale
@onready var y_sort: Node2D = $YSort #Donde poner las rocas
@onready var initial_position: Marker2D = $initialPosition #Posicion desde donde empezar a poner los obstaculos
@onready var obstacles: Node2D = $Obstacles #Donde colocar los obstaculos

@onready var exit_rocks: Node2D = $YSort/ExitRocks #Para tapar la salida, cuando se matan a todos los enemeigos, que se abra (eliminamos las rocas)

#umbrales de ruido
@export var enemy_threshols: float = 0.1 #Enemigos
@export var rock_threshold: float = 0.2 #Rocas (Normales y pinchudas)
@export var obstacle_threshold: float = 0.3 #Obstaculos grandes

var occupancy: Array = [] #Grid para marcar que zonas estan ocupadas y no superponer obstaculos

func _ready() -> void:
	_init_occupancy()
	_create_map()

func _create_map() -> void:
	noise.seed = randi() #Crea una semilla aleatoria
	for y in range(height):
		for x in range(width):
			if occupancy[y][x]: #Solo sigue si la casilla no esta ocupada
				continue
			#var x: float = i
			#var y: float = j
			
			var n = noise.get_noise_2d(x/sc, y/sc)
			print(n)
			#Vemos la probabilidad de un obstaculo grande
			if n > obstacle_threshold:
				_try_place_large_obstacle(x,y) #Probamos a ver si cabe el obstaculo
				#pass
			#Vemos la probailidad de una roca
			elif n > rock_threshold:
				_try_place_rock(x,y)
			else: #Probamos a colocar un enemigo
				#_try_place_enemy(x,y)
				pass
				
func _try_place_rock(x:int, y:int) -> void:
	if occupancy[y][x] or arrayRocks.is_empty():
		return
	var rock_scene = arrayRocks.pick_random() #Cogemos una roca aleatoria
	var rock = rock_scene.instantiate()
	
	#Marcamos la casilla como ocupada
	occupancy[y][x] = true
	#La posiconamos
	var pos = initial_position.global_position+Vector2(x * TILE_SIZE + TILE_SIZE/2, y * TILE_SIZE + TILE_SIZE/2)
	rock.global_position = pos
	y_sort.add_child(rock)

func _try_place_large_obstacle(x: int, y: int) -> void:
	if arrayObstacles.is_empty():
		return

	var obstacle_scene = arrayObstacles.pick_random()
	var ob = obstacle_scene.instantiate()

	# Debe tener width_tiles y height_tiles definidos en su script
	var w = ob.width
	var h = ob.height

	# Si no cabe → no colocarlo
	if not _is_free(x, y, w, h):
		ob.queue_free()
		return

	# Ocupar
	_occupy(x, y, w, h)

	# Posición en píxeles (centrado)
	#var pos = initial_pos.global_position + Vector2(
	#	x * tile_size,
	#	y * tile_size
	#)

	ob.global_position = initial_position.global_position+Vector2(x * TILE_SIZE, y*TILE_SIZE)
	obstacles.add_child(ob)



#Miramos si estam libres las cadillas para colocar el obstaculo
func _is_free(x: int, y: int, w: int, h: int) -> bool:
	for dy in range(h):
		for dx in range(w):
			var cx = x + dx
			var cy = y + dy
			if cx < 0 or cx >= width or cy < 0 or cy >= height:
				return false
			if occupancy[cy][cx]:
				return false
	return true

#Marcamos como ocupoadas en el array las celdas que ocupa la escena que hemos añadido
func _occupy(x: int, y: int, w: int, h: int) -> void:
	for dy in range(h):
		for dx in range(w):
			occupancy[y + dy][x + dx] = true

#Recorremos el grid de ocupados e inicializamos todo a false
func _init_occupancy() -> void:
	occupancy.clear()
	for j in range(height):
		var row := []
		for i in range(width):
			row.append(false)
		occupancy.append(row)
