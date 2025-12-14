extends CanvasLayer
@onready var enemy_counter: Label = $Control/HBoxContainer/EnemyCounter

func _ready() -> void:
	GameManager.enemies_progress_changed.connect(_on_enemies_progress_changed)
	
func _on_enemies_progress_changed(defeated: int, total: int) -> void:
	enemy_counter.text = str(defeated, " / ", total)
