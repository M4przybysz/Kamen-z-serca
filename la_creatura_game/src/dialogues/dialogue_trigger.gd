extends Area2D

@onready var ui: Control = $"../../../UI/UI"

var dialogue_triggered: bool = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") && !dialogue_triggered:
		ui.print_scene()
		dialogue_triggered = true
		get_tree().paused = true
