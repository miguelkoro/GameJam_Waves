extends Bullet
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	super._ready()  # IMPORTANTE: Llamar al _ready del padre
	
	# Configurar propiedades específicas de esta bala
	max_lifetime = 3.0
	# No necesitas configurar speed y damage aquí porque
	# el arma los pasa con initialize()

# OPCIONAL: Si quieres efectos visuales específicos
func _on_area_entered(area: Area2D) -> void:
	# Puedes añadir partículas, sonido, etc. antes de destruir
	super._on_area_entered(area)  # Llama a la función del padre
