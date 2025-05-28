extends Control

@export var main_menu: Control

func _on_exit_button_down() -> void:
	hide()
	main_menu.show()

func _on_resume_button_down() -> void:
	hide()
	get_tree().paused = false
