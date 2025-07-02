extends Node2D

@onready var arena_lock: CollisionShape2D = $Environment/ArenaClosing/ArenaLock/CollisionShape2D

@onready var attack_player: AnimationPlayer = $Body/AttackPlayer

# Assign Timers to variables
@onready var attack_cooldown_timer: Timer = $Timers/AttackCooldownTimer

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
	# Add more values here (format "attack_name" : damage)
}

# Possible attacks:
# 0 - 
# 1 - 
# 2 - 
# 3 - 
# 4 - 
# 5 - 

# Attack patterns
const attack_patterns1 = [
	[],
	[],
	[]
]

const attack_patterns2 = [
	[],
	[],
	[]
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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
