extends Node2D
@onready var PLAYER = "res://src/player/player.tscn"
@onready var collision: CollisionShape2D = $Area2D/Collision

func _on_area2d_entered() -> void:
	PLAYER.movement_speed += 2000
	print(PLAYER.movement_speed)
