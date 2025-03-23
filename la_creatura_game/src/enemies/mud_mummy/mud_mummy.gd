extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var normal_collision: CollisionShape2D = $NormalCollision
@onready var hurtbox_collision: CollisionShape2D = $Hurtbox/CollisionShape2D
@onready var reset_hp_timer: Timer = $Timers/ResetHPTimer
@onready var charge_timer: Timer = $Timers/ChargeTimer
@onready var wrap_timer: Timer = $Timers/WrapTimer

@onready var player: CharacterBody2D = $"../../../Player"

# Movement variables 
@export var movement_speed_input = 150.0
var movement_speed
var starting_point: Vector2
var left_movement_limit: float
var right_movement_limit: float
var target: float
@export var movement_range_left: int = 400
@export var movement_range_right: int = 400

# Combat variables
@export var max_hp: int = 3
var hp: int
var dmg_source_count = 0
var dmg_taken = 0
var dmg_dictionary = { # Disctionary used to determine the dmg taken by the player by the name of the enemy's attack
	"wing_attack" : 1,
	"stone_feather" : 1,
	"copper_feather" : 1,
	"bronze_feather" : 3,
	# Add more values here (format "attack_name" : damage)
}

# Dynamic playthrough variables
var state = "idle"
var direction = 0
var seesPlayer = false
var playerInRange = false
var playerInChargeRange = false
var isWrapping = false
var isCharging = false

func _ready() -> void:
	starting_point = global_position
	left_movement_limit = starting_point.x - movement_range_left
	right_movement_limit = starting_point.x + movement_range_right
	hp = max_hp
	target = global_position.x
	movement_speed = movement_speed_input

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if !is_on_floor():
		velocity += get_gravity() * delta
	
	# Decide what to do
	state_machine()
	
	# Animate enemy
	flip_h()
	# animated_sprite_2d.play(state)
	
	velocity.x = direction * movement_speed

	move_and_slide()

#########################################
# State machine handling
#########################################
func state_machine():
	check_distance_to_player()
	
	match state:
		"idle":
			if hp <= 0:
				state = "die"
			elif seesPlayer:
				state = "combat"
			else:
				state = "idle_movement"
		"idle_movement":
			if seesPlayer:
				state = "combat"
			else:
				idle_movement()
		"combat":
			if hp <= 0:
				state = "die"
			elif !seesPlayer:
				state = "idle"
			elif playerInChargeRange:
				state = "charge"
			elif !playerInRange:
				state = "combat_movement"
			elif playerInRange && !wrap_timer.paused:
				state = "wrap_round_player"
			else:
				state = "idle"
		"combat_movement":
			if playerInRange || !seesPlayer:
				state = "combat"
			elif playerInChargeRange:
				state = "charge"
			else:
				combat_movement()
		"wrap_round_player":
			if !playerInRange || !seesPlayer:
				state = "combat"
			else:
				wrap_round_player()
		"charge":
			if !playerInChargeRange || !seesPlayer:
				state = "combat"
			else:
				charge()
		"die":
			die()
		_:
			print("undefined state")

#########################################
# Direction change handling
#########################################
func flip_h():
	if direction > 0:
		animated_sprite_2d.flip_h = false
	elif direction < 0:
		animated_sprite_2d.flip_h = true

#########################################
# Hitboxes and hurtboxes handling
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

#########################################
# Timers handling
#########################################
func _on_reset_hp_timer_timeout() -> void:
	hp = max_hp
	print(hp)
	reset_hp_timer.stop()

func _on_charge_timer_timeout() -> void:
	charge_timer.stop()

func _on_wrap_timer_timeout() -> void:
	wrap_timer.stop()

#########################################
# Combat handling
#########################################
func decrease_hp(value: int) -> void:
	if hp - value > 0: 
		hp -= value
	else:
		hp = 0
	print(hp)

func die() -> void:
	# TODO: Add death animation
	print("Deleting enemy...")
	queue_free()

func charge() -> void:
	pass

func wrap_round_player() -> void:
	pass

func check_distance_to_player() -> void:
	if player.global_position.x < left_movement_limit || player.global_position.x > right_movement_limit || global_position.x > right_movement_limit || global_position.x < left_movement_limit:
		seesPlayer = false
		if hp < max_hp && reset_hp_timer.is_stopped():
			reset_hp_timer.start()
	else: 
		seesPlayer = true
		playerInChargeRange = abs(player.global_position.x - global_position.x) > 400
		playerInRange = !abs(player.global_position.x - global_position.x) > 50

func combat_movement() -> void:
	movement_speed = movement_speed_input
	target = player.global_position.x
	
	if target > global_position.x:
		direction = 1
	elif target < global_position.x:
		direction = -1
	else:
		direction = 0

func idle_movement() -> void:
	movement_speed = movement_speed_input
	if global_position.x < target + 3 && global_position.x > target - 3:
		target = randi() % int(right_movement_limit - left_movement_limit) + left_movement_limit

	if target > global_position.x:
		direction = 1
	elif target < global_position.x:
		direction = -1
	else:
		direction = 0
