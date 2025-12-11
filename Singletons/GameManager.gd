extends Node

var currency: int = 0
var currencyMulti: float = 1 #Multiplicador de items spawneados relacionados con el dinero
var healingMulti: float = 1

var enemiesToDefeat: int = 0 # numero de enemgios que hay que derrotar en la habitacion para poder avanzar
var enemiesDefeated: int = 0 #Numero de enemigos derrotados en la habitacion
 #Para guardar las perlas

func add_currency(amount: int):
	currency += amount

func enemyDefeated():
	enemiesDefeated+=1
	
func setNewRoom(enemies: int):
	enemiesDefeated = 0
	enemiesToDefeat = enemies

func checkCompleteRoom() -> bool:
	if enemiesToDefeat <= enemiesDefeated:
		return true
	else: 
		return false
