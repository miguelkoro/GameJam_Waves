extends Node

var currency: float = 0 #Para guardar las perlas

func add_currency(amount: float):
	currency += amount
	update_currency_gui()


func update_currency_gui():
	var gui = get_tree().get_first_node_in_group("PearlsUI")
	#gui.update_hearts(last_health, health)
