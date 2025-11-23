extends Node

@export var health: float = 3 #Vida del personaje
#@export var max_health: float = 7 #Corazones maximos que puede tener
@export var max_health: float = 3 #Corazones que tiene disponibles
@export var agility: float = 120 #Velocidad a la que se mueve
@export var strenght: float = 20 #Daño que hace a los enemigos (mas luego lo que haga el arma de daño)
@export var endurance: float = 50 #Resistencia a los ataques

#Funcion para contabilizar el daño recibido
func take_damage(amount: float) -> void:
	if health - amount <= 0:
		#PONER AQUI LAS COSAS DE MORRISE, ANIMACION, ESCENAS...	
		print("Muerto")
	health -= amount
	#print("Health ", health)
	update_hearts_ui()

	

func healing(amount: float) -> void:
	if (health+amount)/2 > max_health:
		return		
	health += amount

func update_hearts_ui() -> void:
	var gui = get_tree().get_first_node_in_group("HeartsUI")
	gui.update_hearts()
