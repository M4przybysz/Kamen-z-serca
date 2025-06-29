extends Node2D

@onready var ui: Control = $UI/UI
@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Player/Camera2D

@onready var great_oak: Node2D = $Alfa_v1/GreatOak

@export var main: Node
@export var death_menu: Control

var player_level: int = 1
var max_hp: int = 2 + player_level
var hp: int
var revive_position: Vector2 = Vector2(750, 200)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hp = max_hp
	# player.ascend_to_level_3()
	# load_level(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _input(_event: InputEvent) -> void:
	if Input.is_action_pressed("look_down"):
		move_camera(0, 100)
	
	if Input.is_action_pressed("look_up"):
		move_camera(0, -100)
	
	if Input.is_action_just_released("look_down") || Input.is_action_just_released("look_up"):
		camera.global_position = player.global_position

func move_camera(x: float, y: float):
	camera.global_position = player.global_position + Vector2(x, y)

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
	if hp == max_hp:
		ui.set_max_hp()

func revive_player() -> void:
	player.global_position = revive_position
	player.state = "idle"
	player.is_grabbing = false
	hp = max_hp
	ui.set_max_hp()
	great_oak.reset_fight()

func set_checkpoint(checkpoint_position: Vector2) ->void:
	revive_position = checkpoint_position
	#print(revive_position)

func player_level_up() -> void:
	player_level += 1
	max_hp = 2 + player_level
	hp = max_hp
	#print(player_level, max_hp, hp)

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
