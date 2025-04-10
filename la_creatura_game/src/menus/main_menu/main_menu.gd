extends Control

@onready var main: Node = $"../.."
@onready var music: AudioStreamPlayer = $"../../Music"

func _ready() -> void:
	get_tree().paused=true

func _on_exit_button_down() -> void:
	main.get_tree().quit()


func _on_play_button_down() -> void:
	hide()
	get_tree().paused=false
	
