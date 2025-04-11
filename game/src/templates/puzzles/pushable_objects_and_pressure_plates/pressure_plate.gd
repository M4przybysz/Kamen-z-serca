extends StaticBody2D

@onready var plate_collision: CollisionShape2D = $CollisionShape2D3
@onready var plate_color: ColorRect = $CollisionShape2D3/ColorRect3
@onready var block_detection: CollisionShape2D = $CollisionShape2D3/Area2D/CollisionShape2D
@onready var movement_lock_timer: Timer = $MovementLockTimer

@export var connected_thing: StaticBody2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("pushable_object"):
		plate_collision.set_deferred("disabled", true)
		block_detection.set_deferred("disabled", true)
		plate_color.visible = false
		body.queue_free()
		do_the_thing()

func do_the_thing() -> void:
	connected_thing.activate()
