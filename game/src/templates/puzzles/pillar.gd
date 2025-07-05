extends RigidBody2D

var left_check: bool = false
var right_check: bool = false
var on_plate: bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if (right_check && left_check) || on_plate:
		freeze = true
	else:
		freeze = false

func _on_left_check_body_entered(_body: Node2D) -> void:
	left_check = true

func _on_right_check_body_entered(_body: Node2D) -> void:
	right_check = true

func _on_left_check_body_exited(_body: Node2D) -> void:
	left_check = false

func _on_right_check_body_exited(_body: Node2D) -> void:
	right_check = false
