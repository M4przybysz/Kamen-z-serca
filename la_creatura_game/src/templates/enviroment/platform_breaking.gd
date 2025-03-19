extends StaticBody2D

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var break_collision: CollisionShape2D = $Area2D/CollisionShape2D
@onready var texture_rect: TextureRect = $TextureRect
@onready var timer: Timer = $Timer

@export var texture_file: ImageTexture
@export var width: int = 100
@export var height: int = 25
@export var break_counter: int = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# texture_rect.texture=texture_file
	collision.shape.size.x = width
	collision.shape.size.y = height
	collision.position = Vector2(width/2, height/2)

func _physics_process(delta: float) -> void:
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		break_counter -= 1
		if break_counter == 0 && timer.is_stopped():
			break_platform()
	
func break_platform() -> void:
	visible = false
	break_collision.set_deferred("disabled", true)
	collision.set_deferred("disabled", true)
	timer.start()

func _on_timer_timeout() -> void:
	timer.stop()
	visible = true
	break_collision.set_deferred("disabled", false)
	collision.set_deferred("disabled", false)
	break_counter = 3
