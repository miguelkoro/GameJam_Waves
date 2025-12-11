extends Node2D

@export var bonusRoom: PackedScene
@export var rooms: Array[PackedScene]

var roomsLogic: Array = ["Room", "bonusRoom", "Room", "Exit"] #Indicamos que tipo de sala tocaria
var roomPointer: int = 0 #Para indicar en el array en que room estamos

var actualRoom: Node2D

func _ready() -> void:
	actualRoom = rooms.pick_random().instantiate()
	actualRoom.global_position = global_position
	add_child(actualRoom)
