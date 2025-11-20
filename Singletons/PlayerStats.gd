extends Node

@export var health: float = 7 #Ponerle 7 corazones (del rollo gato de 7 vidas?)
@export var max_health: float = 7 #Vida maxima 
@export var agility: float = 120 #Velocidad a la que se mueve
@export var strenght: float = 20 #Daño que hace a los enemigos (mas luego lo que haga el arma de daño)
@export var endurance: float = 50 #Resistencia a los ataques

#Funcion para contabilizar el daño recibido
func take_damage(amount: float) -> void:
	health -= amount

func healing(amount: float) -> void:
	health += amount
