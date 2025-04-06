extends StaticBody2D

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var break_collision: CollisionShape2D = $Area2D/CollisionShape2D
@onready var texture_rect: TextureRect = $TextureRect
@onready var timer: Timer = $Timer

@export var texture_file: Texture2D
@export var width: int = 100
@export var height: int = 25
@export var break_counter: int = 3
@export var respawn: bool = true
@export var ignore_player: bool = false
@export var detect_blocks: bool = false
@export var connected_block: RigidBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if texture_file:
		texture_rect.texture = texture_file
	collision.shape = RectangleShape2D.new()
	collision.shape.size = Vector2(width, height)
	collision.position = Vector2(width / 2, height / 2)
	texture_rect.size = Vector2(width, height)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") && !ignore_player:
		count_break()
	
	if body.is_in_group("pushable_object") && detect_blocks:
		if connected_block:
			if body == connected_block:
				count_break()
		else:
			count_break()

func count_break() -> void:
	break_counter -= 1
	if break_counter == 0 && timer.is_stopped():
		break_platform()

func break_platform() -> void:
	visible = false
	break_collision.set_deferred("disabled", true)
	collision.set_deferred("disabled", true)
	if respawn:
		timer.start()

func _on_timer_timeout() -> void:
	timer.stop()
	visible = true
	break_collision.set_deferred("disabled", false)
	collision.set_deferred("disabled", false)
	break_counter = 3
