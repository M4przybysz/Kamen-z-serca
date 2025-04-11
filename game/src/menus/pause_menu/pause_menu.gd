extends Control

@export var main: Node

func _on_exit_button_down() -> void:
	main.get_tree().quit()

func _on_resume_button_down() -> void:
	hide()
	get_tree().paused = false
