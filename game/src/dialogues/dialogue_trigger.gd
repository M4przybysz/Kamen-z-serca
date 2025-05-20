extends Area2D

@onready var ui: Control = $"../../UI/UI"
@export var dialogue_box_position:Vector2=Vector2(1320,500)
@export var one_time_trigger: bool = true

var dialogue_triggered: bool = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") && (!one_time_trigger || (one_time_trigger && !dialogue_triggered)):
		ui.print_scene(dialogue_box_position)
		dialogue_triggered = true
		body.movement_lock = true
