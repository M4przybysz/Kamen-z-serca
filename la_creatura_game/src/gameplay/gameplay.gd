extends Node2D

@onready var ui: Control = $UI/UI
@onready var death_menu: Control = $UI/DeathMenu

var max_hp: int = 3
var hp: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hp = max_hp

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func decrease_hp(value:int) -> void:
	if hp > 0: hp -= value
		
	if hp >= 0 and hp < max_hp:
		ui.set_hp(hp)
	if hp <= 0:
		death_menu.visible = true
	
