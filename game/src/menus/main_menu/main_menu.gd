extends Control

func _ready() -> void:
	get_tree().paused = true

func _on_exit_button_down() -> void:
	get_tree().quit()

func _on_play_button_down() -> void:
	hide()
	get_tree().paused = false
	
