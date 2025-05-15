extends Node2D

@export var one_time_use: bool = false
var used: int = 0

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if one_time_use == false || (one_time_use == true && used <= 0): 
			used += 1
			do_something()

func do_something() -> void:
	print("I'm doing something :3")
