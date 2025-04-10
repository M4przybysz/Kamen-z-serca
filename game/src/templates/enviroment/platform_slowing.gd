extends StaticBody2D

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var texture_rect: TextureRect = $TextureRect

@export var texture_file: Texture2D
@export var width: int = 100
@export var height: int = 25

func _ready() -> void:
	if texture_file:
		texture_rect.texture = texture_file
	collision.shape = RectangleShape2D.new()
	collision.shape.size = Vector2(width, height)
	collision.position = Vector2(width / 2, height / 2)
	texture_rect.size = Vector2(width, height)
