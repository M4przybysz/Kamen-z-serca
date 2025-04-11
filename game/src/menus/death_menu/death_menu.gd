extends Control

@export var main: Node

func _on_exit_button_down() -> void:
	main.get_tree().quit()

func _on_tryagain_button_down() -> void:
	hide()
	get_tree().paused=false
	main.get_tree().reload_current_scene()
