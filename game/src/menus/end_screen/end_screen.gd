extends Control

@export var main: Node

func _on_button_button_down() -> void:
	visible = false
	get_tree().paused = false
	#get_tree().quit()
