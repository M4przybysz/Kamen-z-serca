extends Control

@export var main: Node

func _on_button_button_down() -> void:
	get_tree().quit()
