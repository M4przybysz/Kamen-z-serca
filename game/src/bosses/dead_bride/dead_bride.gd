extends Node2D

# Arena door
@onready var arena_lock: CollisionShape2D = $Environment/ArenaClosing/ArenaLock/CollisionShape2D

# Assign AnimationPlayer to variables
@onready var attack_player: AnimationPlayer = $Body/AttackPlayer

# Assign Timers to variables
@onready var attack_cooldown_timer: Timer = $Timers/AttackCooldownTimer

# Hurtbox collisions
@onready var hurtbox_collision_1: CollisionShape2D = $Body/Hurtbox/CollisionShape1
@onready var hurtbox_collision_2: CollisionShape2D = $Body/Hurtbox/CollisionShape2

# Main stuff
@onready var ui: Control = $"../../UI/UI"
@onready var main: Node = $"../../../"

# Constant variables
const max_hp: int = 30
const dmg_dictionary = { # Disctionary used to determine the dmg taken by the player by the name of the enemy's attack
	"wing_attack" : 1,
	"stone_feather" : 1,
	"copper_feather" : 1,
	"bronze_feather" : 2,
	"spear" : 3,
	"spike" : 1,
	# Add more values here ("attack_name" : damage)
}

# Possible attacks:
# 0 - reset pattern
# 1 - breaking walls
# 2 - hit and wave (only in phase one)
# 3 - floor is lava
# 4 - fall on spikes
# 5 - falling stones

# Possible counter attacks 
# 0 - throw feather back
# 1 - punch back
# 2 - falling stone

# Attack patterns
const attack_patterns1 = [
	[6, 3, 1, 0],
	[1, 2, 4, 5],
	[1, 4, 6, 2]
]

const attack_patterns2 = [
	[4, 5, 3, 4, 5, 3],
	[1, 4, 4, 5],
	[6, 6, 1, 4, ]
]

# Dynamic variables
var hp: int
var is_in_fight: bool = false
var dmg_source_count: int
var dmg_taken: int
var unlock_arena: bool = false
var fight_phase: int = 1
var platform_set: int = 1
var bride_position: int = 0
var active_attack_pattern: Array
var active_attack_index: int = 0
var active_warning: int

# Random number generator
var RNG = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hp = max_hp
	active_attack_pattern = attack_patterns1[RNG.randi_range(0, 2)]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Don't do anything unless the fight starts
	if unlock_arena && !arena_lock.disabled:
		arena_lock.disabled = true
		arena_lock.visible = false
	
	if !is_in_fight: return
	
	#state_machine()

#########################################
# Starting a bloodbath
#########################################
func start_fight() -> void:
	is_in_fight = true
	attack_cooldown_timer.start()
	ui.show_boss_hp_bar("OBLUBIENICA")

#########################################
# Normal attacks handling
#########################################
func reset_attack_pattern() -> void:
	active_attack_index = 0
	if fight_phase == 1:
		active_attack_pattern = attack_patterns1[RNG.randi_range(0, 2)]
	elif fight_phase == 2:
		active_attack_pattern = attack_patterns2[RNG.randi_range(0, 2)]

func breaking_walls() -> void:
	print("breaking walls")

func hit_and_wave() -> void:
	print("hit and wave")

func floor_is_lava() -> void:
	print("floor is lava")

func fall_on_spikes() -> void:
	print("fall on spikes")

func falling_stones() -> void:
	print("falling stones")

func _on_attack_cooldown_timer_timeout() -> void:
	attack_cooldown_timer.stop()
	
	if is_in_fight:
		match active_attack_pattern[active_attack_index]:
			0: reset_attack_pattern()
			1: breaking_walls()
			2: hit_and_wave()
			3: floor_is_lava()
			4: fall_on_spikes()
			5: falling_stones()
			_: print("This pokemon doesn't know a move number ", active_attack_pattern[active_attack_index])
		
		active_attack_index += 1
		if active_attack_pattern[active_attack_index] == active_attack_pattern[-1]:
			reset_attack_pattern()
		attack_cooldown_timer.start()

#########################################
# Counter attacks handling
#########################################
func counter_feather() -> void:
	pass

func counter_melee() -> void:
	pass

func teleport() -> void:
	pass

#########################################
# Arena changes handling
#########################################

#########################################
# HP handling
#########################################
func _on_hurtbox_area_entered(area: Area2D) -> void:
	if is_in_fight:
		if fight_phase == 1 && (area.is_in_group("spear") || area.is_in_group("stone_feather") || area.is_in_group("copper_feather") || area.is_in_group("bronze_feather")):
			return
		else:
			dmg_source_count += 1
			for group in dmg_dictionary:
				if area.is_in_group(group):
					dmg_taken += dmg_dictionary[group]
			decrease_hp(floor(dmg_taken/dmg_source_count))

func _on_hurtbox_area_exited(area: Area2D) -> void:
	if is_in_fight:
		if fight_phase == 1 && (area.is_in_group("spear") || area.is_in_group("stone_feather") || area.is_in_group("copper_feather") || area.is_in_group("bronze_feather")):
			return
		else:
			dmg_source_count -= 1
			for group in dmg_dictionary:
				if area.is_in_group(group):
					dmg_taken -= dmg_dictionary[group]

func decrease_hp(value: int) -> void:
	if hp - value > 0: 
		hp -= value
		ui.set_boss_hp(max_hp, hp)
		#reset_attack_pattern()
	else:
		hp = 0
		ui.hide_boss_hp_bar()
		is_in_fight = false
		unlock_arena = true
		main.show_end_screen()
	if hp <= max_hp / 2:
		fight_phase = 2
	#print(hp)
