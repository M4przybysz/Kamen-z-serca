extends StaticBody2D

@onready var collision: CollisionShape2D = $CollisionShape2D

var player_on_top: bool = false

func _input(_event: InputEvent) -> void:
	if Input.is_action_pressed("look_down") && player_on_top:
		collision.disabled = true
	
	if Input.is_action_just_released("look_down"):
		collision.disabled = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_on_top = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_on_top = false
