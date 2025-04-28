extends Area2D

@onready var collision: CollisionShape2D = $CollisionShape2D
@export var gameplay: Node2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		gameplay.decrease_hp(100)
