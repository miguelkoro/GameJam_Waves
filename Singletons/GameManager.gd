extends Node

var currency: int = 0
var dropMulti: float = 1 #Multiplicador de items spawneados relacionados con el dinero
var healingMulti: float = 1
var enemiesMulti: float = 1

var enemiesToDefeat: int = 0 # numero de enemgios que hay que derrotar en la habitacion para poder avanzar
var enemiesDefeated: int = 0 #Numero de enemigos derrotados en la habitacion


func add_currency(amount: int):
	currency += amount

func enemyDefeated():
	enemiesDefeated+=1
	if checkCompleteRoom():
		var room = get_tree().get_first_node_in_group("Room")
		room._open_exit()
	
func nextRoom():
	var run = get_tree().get_first_node_in_group("Run")
	run.changeRoom()

func checkCompleteRoom() -> bool:
	if enemiesToDefeat <= enemiesDefeated:
		return true
	else: 
		return false
