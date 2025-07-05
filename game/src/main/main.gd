extends Node

@onready var pause_menu: Control = $Menus/PauseMenu
@onready var death_menu: Control = $Menus/DeathMenu
@onready var main_menu: Control = $Menus/MainMenu
@onready var end_screen: Control = $Menus/EndScreen

@onready var las_walka: AudioStreamPlayer = $"Musica/LasWalka1"
@onready var las_spokoj: AudioStreamPlayer = $"Musica/LasSpokoj1"
@onready var drzewo_spokoj: AudioStreamPlayer = $"Musica/DrzewoSpokój"
@onready var drzewo_walka: AudioStreamPlayer = $Musica/DrzewoWalka

@export var player: CharacterBody2D
@export var gameplay: Node2D
var combat_counter: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = true
	main_menu.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("quit") && main_menu.visible == false && get_tree().paused == false:
		if !get_tree().paused:
			pause_menu.visible = true
			get_tree().paused = true
		elif pause_menu.visible == true:
			pause_menu.visible = false
			get_tree().paused = false

func show_death_menu():
	death_menu.visible = true
	get_tree().paused = true

func show_end_screen():
	end_screen.visible = true
	player.global_position = Vector2(11225, -8995)
	player.is_shield_unlocked = true
	player.is_spear_unlocked = true
	gameplay.revive_position = Vector2(11225, -8995)
	get_tree().paused = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("mud_mummy"):
		combat_counter+=1
		#print(combat_counter)
		if combat_counter > 0:
			las_spokoj.volume_db = -80
			las_walka.volume_db = 0

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("mud_mummy"):
		combat_counter-=1
		#print(combat_counter)
		if combat_counter <= 0:
			las_spokoj.volume_db = 0
			las_walka.volume_db = -80
