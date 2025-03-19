extends StaticBody2D

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var texture_rect: TextureRect = $TextureRect

@export var texture_file: ImageTexture
@export var width: int = 100
@export var height: int = 25

func _ready() -> void:
	texture_rect.texture=texture_file
	collision.shape.size.x = width
	collision.shape.size.y = height
	collision.position = Vector2(width/2, height/2)
