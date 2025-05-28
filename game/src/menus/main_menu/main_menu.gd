extends Control

@export var gameplay: Node2D

func _on_exit_button_down() -> void:
	get_tree().quit()

func _on_play_button_down() -> void:
	hide()
	get_tree().paused = false
	if gameplay.hp <= 0:
		get_tree().reload_current_scene()
