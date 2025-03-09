extends Node2D

@onready var ui: Control = $UI/UI
@onready var death_menu: Control = $UI/DeathMenu
@onready var player: CharacterBody2D = $Player

var player_level: int = 1
var max_hp: int = 2 + player_level
var hp: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hp = max_hp
	# player.ascend_to_level_3()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func decrease_hp(value: int) -> void:
	if hp - value > 0: 
		hp -= value
	else:
		hp = 0
	if hp >= 0 and hp < max_hp:
		ui.set_hp(hp)
	if hp <= 0:
		death_menu.visible = true

func increase_hp(value: int) -> void:
	if hp + value < max_hp:
		hp += value
	else:
		hp = max_hp
	if hp >= 0 and hp < max_hp:
		ui.set_hp(hp)

func player_level_up() -> void:
	player_level += 1
	max_hp = 2 + player_level
	hp = max_hp
	print(player_level, max_hp, hp)
