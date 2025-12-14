extends Node2D

var countEnemy: bool = true
var drop_item: PackedScene
@export var healItems: Array[PackedScene]
@export var coinItems: Array[PackedScene]
@export var healItemsRare: Array[PackedScene]
@export var coinItemsRare: Array[PackedScene]

@export var drop_chance: float = 0.5
@export var rare_chance: float = 0.1
@export var health_item_chance: float = 0.4 #40% drop salud, 60% dineros
@export var explosion: bool = false

func _on_animated_sprite_enemy_death_animation_finished() -> void:
	if countEnemy:
		GameManager.enemyDefeated()
	if not explosion:
		_drop_item()
	queue_free()

func _drop_item() -> void:
	if randf() > drop_chance * GameManager.dropMulti: #No dropea nada 
		return
	var is_rare = randf() < rare_chance #true, dropea objeto raro
	var is_health = randf() < health_item_chance #true: dropea objeto de salud, false, drop monedas
	
	if is_health:
		if is_rare:
			drop_item = healItemsRare.pick_random()
		else:
			drop_item = healItems.pick_random()
	else:
		if is_rare:
			drop_item = coinItemsRare.pick_random()
		else:
			drop_item = coinItems.pick_random()
	if drop_item == null:
		return
	var item = drop_item.instantiate()
	item.global_position = global_position
	get_parent().add_child(item)
