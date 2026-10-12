extends Button

func _ready() -> void:
	pressed.connect(on_pressed)

func on_pressed():
	get_tree().change_scene_to_file("res://scenes/categories/actions_and_commands/pin_word.tscn")
	pass
