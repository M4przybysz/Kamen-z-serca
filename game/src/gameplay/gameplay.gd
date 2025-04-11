extends Node2D

@onready var ui: Control = $UI/UI
@onready var player: CharacterBody2D = $Player

@export var main: Node
@export var death_menu: Control

var player_level: int = 1
var max_hp: int = 2 + player_level
var hp: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hp = max_hp
	# player.ascend_to_level_3()
	# load_level(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func decrease_hp(value: int) -> void:
	if hp - value > 0: 
		hp -= value
	else:
		hp = 0
	if hp >= 0 and hp < max_hp:
		ui.set_hp(hp)
	if hp <= 0:
		main.show_death_menu()

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

func load_level(level_number: int) -> void:
	var level_paths = {
		0 : "res://src/test_elements/levels/programmers_playground.tscn",
		1 : "res://src/levels/level_1.tscn",
		2 : "res://src/levels/level_2.tscn",
		3 : "res://src/levels/level_3.tscn",
	}
	remove_child(get_child(0))
	var new_level = load(level_paths[level_number]).instantiate()
	add_child(new_level)
	move_child(get_child(-1), 0)
