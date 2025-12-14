extends Node2D

func _ready() -> void:
	PlayerStats.healing(100)
	GameManager.enemiesDefeated=0
	GameManager.enemiesToDefeat=0
	GameManager.dropMulti = 1
	GameManager.enemiesMulti = 1
	
