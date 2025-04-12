extends Control

func _on_exit_button_down() -> void:
	get_tree().quit()

func _on_tryagain_button_down() -> void:
	hide()
	get_tree().paused = false
	get_tree().reload_current_scene()
