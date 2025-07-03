extends StaticBody2D

@onready var plate_collision: CollisionShape2D = $CollisionShape2D3
@onready var plate_color: ColorRect = $CollisionShape2D3/ColorRect3

@export var thing_to_open: StaticBody2D
@export var activator: RigidBody2D

var check_right: bool = false
var check_left: bool = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if (activator == null && body.is_in_group("pushable_object")) || (activator != null && body == activator):
		check_right = true
	
	if check_left && check_right && body.is_in_group("pushable_object"):
		plate_color.color = Color(255,255,255)
		body.on_plate = true
		do_the_thing()

func _on_area_2d_2_body_entered(body: Node2D) -> void:
	if (activator == null && body.is_in_group("pushable_object")) || (activator != null && body == activator):
		check_left = true
	
	if check_left && check_right && body.is_in_group("pushable_object"):
		plate_color.color = Color(255,255,255)
		body.on_plate = true
		do_the_thing()

func do_the_thing() -> void:
	thing_to_open.activate()
