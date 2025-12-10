extends Node2D

@export var enemies: Array[PackedScene]

@export var enemies_amount = 5 #Cantidad de enemigos que debe spawnear
var enemies_spawn = 0 #Cantidad de enemigos que ha spawneado
@onready var timer_spawn: Timer = $Timer_Spawn
@onready var y_sort = get_parent().get_parent().get_node("YSort")

func _ready() -> void:
	enemies_spawn = 0
	timer_spawn.start()

func _spawn_enemy() -> void:
	if enemies.is_empty():
		return
		
	enemies_spawn+=1
	var enemy_scene = enemies.pick_random() #Cogemos una roca aleatoria
	var enemy = enemy_scene.instantiate()
	enemy.global_position = global_position
	y_sort.add_child(enemy)

#Spawnea enemigos con el timer
func _on_timer_spawn_timeout() -> void:
	if enemies_spawn >= enemies_amount:
		timer_spawn.stop()
		return
	_spawn_enemy()
