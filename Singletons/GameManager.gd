extends Node

var currency: int = 25
var dropMulti: float = 1 #Multiplicador de items spawneados relacionados con el dinero
var healingMulti: float = 1
var enemiesMulti: float = 1

var enemiesToDefeat: int = 0 # numero de enemgios que hay que derrotar en la habitacion para poder avanzar
var enemiesDefeated: int = 0 #Numero de enemigos derrotados en la habitacion
signal enemies_progress_changed(defeated: int, total: int)

func add_currency(amount: int):
	currency += amount
func remove_currency(amount: int) -> bool:
	if currency - amount >= 0:
		currency -= amount
		return true
	else:
		return false

func add_enemies_to_defeat(amount: int):
	enemiesToDefeat += amount
	emit_signal("enemies_progress_changed", enemiesDefeated, enemiesToDefeat)

func enemyDefeated():
	enemiesDefeated+=1
	emit_signal("enemies_progress_changed", enemiesDefeated, enemiesToDefeat)
	if checkCompleteRoom():
		var room = get_tree().get_first_node_in_group("Room")
		room._open_exit()
	
func nextRoom():
	var run = get_tree().get_first_node_in_group("Run")
	enemiesDefeated = 0
	enemiesToDefeat = 0
	run.changeRoom()

func checkCompleteRoom() -> bool:
	if enemiesToDefeat <= enemiesDefeated:
		return true
	else: 
		return false
func death_currency():
	var lost =  int(currency*0.2)
	currency = max(0, currency - lost) #Para evitar que baje de 0

func restart():
	currency = 25
	dropMulti = 1 
	healingMulti = 1
	enemiesMulti = 1
	enemiesToDefeat = 0 
	enemiesDefeated = 0 
		
