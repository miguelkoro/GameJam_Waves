extends Bullet
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	super._ready()  
	max_lifetime = 3.0

func _on_area_entered(area: Area2D) -> void:
	super._on_area_entered(area) 
