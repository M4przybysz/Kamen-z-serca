extends Node

@onready var pause_menu: Control = $Menus/PauseMenu
@onready var death_menu: Control = $Menus/DeathMenu
@onready var main_menu: Control = $Menus/MainMenu
@onready var music: AudioStreamPlayer = $Music

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused=true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("quit") && main_menu.visible == false:
		if !get_tree().paused:
			pause_menu.visible=true
			get_tree().paused=true
		else:
			pause_menu.visible=false
			get_tree().paused=false

func show_death_menu():
	death_menu.visible=true
	get_tree().paused=true
