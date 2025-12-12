extends Node2D

@export var bonusRoom: PackedScene
@export var rooms: Array[PackedScene]
@export var exitRoom: PackedScene
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var roomsLogic: Array = ["Room", "bonusRoom", "Room", "Exit"] #Indicamos que tipo de sala tocaria
var roomPointer: int = 0 #Para indicar en el array en que room estamos


var actualRoom: Node2D

func _ready() -> void:
	_create_enemy_room()

func changeRoom() -> void:
	roomPointer+=1
	animation_player.play("FadeOut")


func _load_room(scene: PackedScene) -> void:
	#Eliminar sala anterior
		# Eliminar la sala anterior si existe
	if actualRoom and actualRoom.is_inside_tree():
		actualRoom.queue_free()
	# Crear nueva sala
	actualRoom = scene.instantiate()
	actualRoom.global_position = global_position
	add_child(actualRoom)
	animation_player.play("FadeIn")
		
func _create_enemy_room() -> void:
	_load_room(rooms.pick_random())	
	actualRoom._add_enemies(randi_range(1,2)*GameManager.enemiesMulti)
	animation_player.play("FadeIn")
	#actualRoom._add_enemies(1)

func _create_bonus_room() -> void:
	_load_room(bonusRoom)
func _create_exit_room() -> void:
	_load_room(exitRoom)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "FadeOut":
		if roomPointer >= roomsLogic.size(): #Si elegimos continuar con la run, esta se reinicia
			roomPointer = 0		
		match  roomsLogic[roomPointer]:
			"Room":
				_create_enemy_room()
			"bonusRoom":
				_create_bonus_room()
			"Exit":
				_create_exit_room()
