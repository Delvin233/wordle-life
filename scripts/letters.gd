extends PanelContainer

@onready var label: Label = $Label


func set_letter(character: String) -> void:
	label.text = character.to_upper()


func set_color(color: Color) -> void:
	self.self_modulate = color
