extends Node2D

@onready var arena_lock: CollisionShape2D = $Environment/ArenaClosing/ArenaLock/CollisionShape2D

@export var ui: Control

# Constant variables
const max_hp: int = 10
const dmg_dictionary = { # Disctionary used to determine the dmg taken by the player by the name of the enemy's attack
	"wing_attack" : 1,
	"stone_feather" : 1,
	"copper_feather" : 1,
	"bronze_feather" : 2,
	"spear" : 3,
	"spike" : 1,
	# Add more values here (format "attack_name" : damage)
}

# Dynamic variables
var hp: int
var is_in_fight: bool = false
var dmg_source_count: int
var dmg_taken: int
var unlock_arena: bool = false

func _ready() -> void:
	ui.connect("start_oak_fight", start_fight)
	hp = max_hp

func _process(delta: float) -> void:
	# Don't do anything unless the fight starts
	if unlock_arena && !arena_lock.disabled:
		arena_lock.disabled = true
		arena_lock.visible = false
	
	if !is_in_fight: return
	
	print("kill")

func start_fight() -> void:
	is_in_fight = true
	ui.show_boss_hp_bar("GREAT OAK")

#########################################
# HP handling
#########################################
func _on_hurtbox_area_entered(area: Area2D) -> void:
	dmg_source_count += 1
	for group in dmg_dictionary:
		if area.is_in_group(group):
			dmg_taken += dmg_dictionary[group]
	decrease_hp(floor(dmg_taken/dmg_source_count))

func _on_hurtbox_area_exited(area: Area2D) -> void:
	dmg_source_count -= 1
	for group in dmg_dictionary:
		if area.is_in_group(group):
			dmg_taken -= dmg_dictionary[group]

func decrease_hp(value: int) -> void:
	if hp - value > 0: 
		hp -= value
		ui.set_boss_hp(max_hp, hp)
	else:
		hp = 0
		ui.hide_boss_hp_bar()
		is_in_fight = false
		unlock_arena = true
	#print(hp)
