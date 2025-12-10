extends Node

@export var health: float = 2.5 #Vida del personaje
var last_health:float = health #Para poder comparar en la gui si se ha perdido o ganado vida 
#@export var max_health: float = 7 #Corazones maximos que puede tener
@export var max_health: float = 3 #Corazones que tiene disponibles
@export var agility: float = 150 #Velocidad a la que se mueve
@export var strenght: float = 1 #Daño que hace a los enemigos (mas luego lo que haga el arma de daño)
@export var endurance: float = 50 #Resistencia a los ataques
@export var knockback: float = 50 #Retroceso que aplica a los enemigos


#Funcion para contabilizar el daño recibido
func take_damage(amount: float) -> void:
	if health - amount <= 0:
		#PONER AQUI LAS COSAS DE MORRISE, ANIMACION, ESCENAS...	
		print("Muerto")
	last_health = health
	health -= amount
	#print("Health ", health)
	update_hearts_ui()

	

func healing(amount: float) -> void:
	last_health = health
	if health+amount >= max_health:
		health = max_health
	else:
		health += amount	
	update_hearts_ui()

func update_hearts_ui() -> void:
	var gui = get_tree().get_first_node_in_group("HeartsUI")
	gui.update_hearts(last_health, health)
	
func screen_ink_effect() -> void: #Este metodo deberia refactorizarlo y meterlo en u nscript dentro del ColorRect
	var screen = get_tree().get_first_node_in_group("InkEffectUI")
	if screen == null:
		return
	var mat := screen.material as ShaderMaterial
	if mat == null:
		return

	# Activamos
	mat.set_shader_parameter("intensity", 1.0)
	# Fade out suave
	var tween := get_tree().create_tween()
	tween.tween_property(mat, "shader_parameter/intensity", 0.0, 1.1)
