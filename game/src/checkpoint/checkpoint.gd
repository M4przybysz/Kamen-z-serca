extends Node2D

@onready var label_timer: Timer = $LabelTimer
@onready var label: Label = $Label

@export var heal: int = 0

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		label_timer.start()
		label.show()

func _on_label_timer_timeout() -> void:
	label_timer.stop()
	label.hide()
