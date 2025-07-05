extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("pushable_object"):
		body.on_plate = true
