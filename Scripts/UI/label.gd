extends Label

func _process(_delta):
	text = "x " + str(GameManager.currency)
