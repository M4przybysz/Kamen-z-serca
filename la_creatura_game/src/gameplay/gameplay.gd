extends Node2D

var max_hp: int = 3

var hp: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hp = max_hp
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func decrease_hp(value:int) -> void:
	hp-=value
	print(hp)
