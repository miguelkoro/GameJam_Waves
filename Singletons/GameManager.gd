extends Node

var currency: int = 0
var currencyMulti: float = 1 #Multiplicador de items spawneados relacionados con el dinero
var healingMulti: float = 1

 #Para guardar las perlas

func add_currency(amount: int):
	currency += amount
