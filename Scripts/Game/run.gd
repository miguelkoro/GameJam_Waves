extends Node2D

@export var bonusRoom: PackedScene
@export var rooms: Array[PackedScene]

var roomsLogic: Array = ["Room", "bonusRoom", "Room", "Exit"] #Indicamos que tipo de sala tocaria
var roomPointer: int = 0 #Para indicar en el array en que room estamos

var actualRoom: Node2D

func _ready() -> void:
	_create_enemy_room()

func changeRoom() -> void:
	roomPointer+=1
	match  roomsLogic[roomPointer]:
		"Room":
			_create_enemy_room()
		"bonusRoom":
			_create_bonus_room()
		"Exit":
			pass

func _load_room(scene: PackedScene) -> void:
	#Eliminar sala anterior
		# Eliminar la sala anterior si existe
	if actualRoom and actualRoom.is_inside_tree():
		actualRoom.queue_free()
	# Crear nueva sala
	actualRoom = scene.instantiate()
	actualRoom.global_position = global_position
	add_child(actualRoom)
		
func _create_enemy_room() -> void:
	_load_room(rooms.pick_random())	
	actualRoom._add_enemies(randi_range(5,10))
	#actualRoom._add_enemies(1)

func _create_bonus_room() -> void:
	_load_room(bonusRoom)
