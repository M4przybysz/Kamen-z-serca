extends Node2D

@onready var arena_lock: CollisionShape2D = $Environment/ArenaClosing/ArenaLock/CollisionShape2D

@onready var attack_player: AnimationPlayer = $Body/AttackPlayer

# Assign Timers to variables
@onready var wind_timer: Timer = $Timers/WindTimer
@onready var attack_cooldown_timer: Timer = $Timers/AttackCooldownTimer

# Assign attack collisions to variables
@onready var wind_collision: CollisionShape2D = $Body/Wind/CollisionShape2D

@export var ui: Control
@onready var main: Node = $"../../../"

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

# Possible attacks:
# 0 - reset pattern
# 1 - short range branch attack
# 2 - long range branch attack
# 3 - moving root on the ground attack
# 4 - spiked roots attack
# 5 - falling acorns attack (breaking leftover acorn creates a health pack)

# Attack patterns
const attack_patterns1 = [
	[2, 3, 1, 0],
	[1, 4, 2, 5, 0],
	[4, 5, 2, 1, 4, 0]
]

const attack_patterns2 = [
	[3, 4, 3, 1, 0],
	[5, 3, 2, 1, 3, 0],
	[4, 3, 1, 5, 2, 1, 0]
]

# Dynamic variables
var hp: int
var is_in_fight: bool = false
var dmg_source_count: int
var dmg_taken: int
var unlock_arena: bool = false
var fight_phase: int = 1
var active_attack_pattern: Array
var active_attack_index: int = 0
var active_warning: int

# Random number generator
var RNG = RandomNumberGenerator.new()

func _ready() -> void:
	ui.connect("start_oak_fight", start_fight)
	hp = max_hp
	active_attack_pattern = attack_patterns1[RNG.randi_range(0, 2)]

func _process(_delta: float) -> void:
	# Don't do anything unless the fight starts
	if unlock_arena && !arena_lock.disabled:
		arena_lock.disabled = true
		arena_lock.visible = false
	
	if !wind_timer.is_stopped(): wind_collision.disabled = false
	
	if !is_in_fight: return
	
	state_machine()
	
	if attack_cooldown_timer.time_left <= 0.5:
		ui.boss_attack_warning(active_warning)

#########################################
# Handling attack patterns
#########################################
func state_machine() -> void:
	print(active_attack_pattern, active_attack_pattern[active_attack_index])
	
	# Show correct attack warning
	match active_attack_pattern[active_attack_index]:
		1, 5: active_warning = 0
		2, 3: active_warning = 1
		4: active_warning = 2
		_: print("idk where the attack is comming from")

#########################################
# Attacks handling
#########################################
func reset_attack_pattern() -> void:
	active_attack_index = 0
	if fight_phase == 1:
		active_attack_pattern = attack_patterns1[RNG.randi_range(0, 2)]
	elif fight_phase == 2:
		active_attack_pattern = attack_patterns2[RNG.randi_range(0, 2)]

func spiked_roots() -> void:
	print("spiked_roots_attack")

func falling_acorns() -> void:
	print("falling_acorns_attack")

#########################################
# Starting a bloodbath
#########################################
func start_fight() -> void:
	is_in_fight = true
	attack_cooldown_timer.start()
	ui.show_boss_hp_bar("GREAT OAK")

#########################################
# HP handling
#########################################
func _on_hurtbox_area_entered(area: Area2D) -> void:
	if is_in_fight:
		dmg_source_count += 1
		for group in dmg_dictionary:
			if area.is_in_group(group):
				dmg_taken += dmg_dictionary[group]
		decrease_hp(floor(dmg_taken/dmg_source_count))

func _on_hurtbox_area_exited(area: Area2D) -> void:
	if is_in_fight:
		dmg_source_count -= 1
		for group in dmg_dictionary:
			if area.is_in_group(group):
				dmg_taken -= dmg_dictionary[group]

func decrease_hp(value: int) -> void:
	if hp - value > 0: 
		hp -= value
		ui.set_boss_hp(max_hp, hp)
		wind_timer.start()
		reset_attack_pattern()
	else:
		hp = 0
		ui.hide_boss_hp_bar()
		is_in_fight = false
		unlock_arena = true
		main.show_end_screen()
	if hp <= max_hp / 2:
		fight_phase = 2
	#print(hp)

#########################################
# Timers handling
#########################################
func _on_wind_timer_timeout() -> void:
	wind_timer.stop()
	wind_collision.disabled = true

func _on_attack_cooldown_timer_timeout() -> void:
	attack_cooldown_timer.stop()
	
	if is_in_fight:
		match active_attack_pattern[active_attack_index]:
			0: reset_attack_pattern()
			1: attack_player.play("short_branch_attack")
			2: attack_player.play("long_branch_attack")
			3: attack_player.play("moving_root_attack")
			4: attack_player.play("spiked_roots_attack")
			5: falling_acorns()
			_: print("This pokemon doesn't know a move number ", active_attack_pattern[active_attack_index])
		
		active_attack_index += 1
		if active_attack_pattern[active_attack_index] == active_attack_pattern[-1]:
			reset_attack_pattern()
		attack_cooldown_timer.start()
