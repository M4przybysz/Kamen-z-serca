extends Control
@onready var main: Node = $"."

func _on_button_button_down() -> void:
	main.get_tree().quit()
