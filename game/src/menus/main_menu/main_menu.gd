extends Control

@export var gameplay: Node2D
@onready var dialogue_interface: Control = $"../../Gameplay/UI/UI/DialogueInterface"
@onready var ui: Control = $"../../Gameplay/UI/UI"

func _on_exit_button_down() -> void:
	get_tree().quit()

func _on_play_button_down() -> void:
	hide()
	get_tree().paused = false
	dialogue_interface.show()
	ui.dialogue_scene = ui.get_scene("#Obraz pierwszy")
	ui.print_scene()
	if gameplay.hp <= 0:
		get_tree().reload_current_scene()
