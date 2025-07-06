extends Area2D

@onready var timer: Timer = $Timer
@onready var label: Label = $Label

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.ascend_to_level_2()
		label.show()
		timer.start()

func _on_timer_timeout() -> void:
	timer.stop()
	label.hide()
	queue_free()
