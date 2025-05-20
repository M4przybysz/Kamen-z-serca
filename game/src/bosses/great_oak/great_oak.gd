extends Node2D

@onready var arena_lock: StaticBody2D = $Environment/ArenaClosing/ArenaLock

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

func _ready() -> void:
	hp = max_hp

func _process(delta: float) -> void:
	# Don't do anything unless the fight starts
	if !is_in_fight: return

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
	else:
		hp = 0
	print(hp)
