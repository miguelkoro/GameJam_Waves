extends Node2D

@export var enemies: Array[PackedScene]

@export var enemies_amount = 5 #Cantidad de enemigos que debe spawnear
var enemies_spawn = 0 #Cantidad de enemigos que ha spawneado
@onready var timer_spawn: Timer = $Timer_Spawn
@onready var y_sort = get_parent().get_parent().get_node("YSort")
const TILE_SIZE: int = 32
@onready var spawn_position: Marker2D = $SpawnPosition
@onready var audio_spawn: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	enemies_spawn = 0
	timer_spawn.start()
	animated_sprite.visible = false

func _spawn_enemy() -> void:
	if enemies.is_empty():
		return
	if not audio_spawn.playing:
		audio_spawn.play()
	animated_sprite.visible = true
	animated_sprite.play("spawn")	
	enemies_spawn+=1
	var enemy_scene = enemies.pick_random() #Cogemos una roca aleatoria
	var enemy = enemy_scene.instantiate()
	enemy.global_position = spawn_position.global_position #Para que salga en medio del remonilo
	y_sort.add_child(enemy)

#Spawnea enemigos con el timer
func _on_timer_spawn_timeout() -> void:
	if enemies_spawn >= enemies_amount:
		timer_spawn.stop()
		return
	_spawn_enemy()


func _on_animated_sprite_2d_animation_finished() -> void:
	animated_sprite.visible = false
