extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var normal_collision: CollisionShape2D = $NormalCollision
@onready var hurtbox_collision: CollisionShape2D = $Hurtbox/CollisionShape2D
@onready var reset_hp_timer: Timer = $Timers/ResetHPTimer
@onready var charge_timer: Timer = $Timers/ChargeTimer
@onready var wrap_cooldown_timer: Timer = $Timers/WrapCooldownTimer

@onready var player: CharacterBody2D = $"../../../Player"
#@export var player: CharacterBody2D

# Movement variables 
@export var movement_speed_input = 100.0
var movement_speed
var starting_point: Vector2
var left_combat_movement_limit: float
var right_combat_movement_limit: float
var left_idle_movement_limit: float
var right_idle_movement_limit: float
var target: float
@export var combat_movement_range_left: int = 500
@export var combat_movement_range_right: int = 500
@export var idle_movement_range_left: int = 300
@export var idle_movement_range_right: int = 300

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
var playerInWrapRange = false
var playerInChargeRange = false
var isWrapping = false

func _ready() -> void:
	starting_point = global_position
	left_combat_movement_limit = starting_point.x - combat_movement_range_left
	right_combat_movement_limit = starting_point.x + combat_movement_range_right
	left_idle_movement_limit = starting_point.x - idle_movement_range_left
	right_idle_movement_limit = starting_point.x + idle_movement_range_right
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
	# Check death
	if hp <= 0:
		die()
	
	check_distance_to_player()
	
	match state:
		"idle":
			if seesPlayer:
				state = "combat"
			else:
				state = "idle_movement"
		"idle_movement":
			if seesPlayer:
				state = "combat"
			else:
				idle_movement()
		"combat":
			if !seesPlayer:
				state = "idle"
			elif playerInChargeRange:
				state = "charge"
			elif playerInWrapRange:
				state = "wrap_round_player"
			else:
				state = "combat_movement"
		"combat_movement":
			if playerInWrapRange || !seesPlayer:
				state = "combat"
			elif playerInChargeRange:
				state = "charge"
			else:
				combat_movement()
		"wrap_round_player":
			if (!playerInWrapRange && !isWrapping) || player.isDashing:
				state = "combat"
			else:
				wrap_around_player()
		"charge":
			if !playerInChargeRange:
				state = "combat"
			else:
				charge()
				state = "combat_movement"
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
			if isWrapping:
				stop_wrapping()
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
	#print(hp)
	reset_hp_timer.stop()

func _on_charge_timer_timeout() -> void:
	movement_speed = movement_speed_input
	charge_timer.stop()

func _on_wrap_cooldown_timer_timeout() -> void:
	wrap_cooldown_timer.stop()

#########################################
# Combat handling
#########################################
func decrease_hp(value: int) -> void:
	if hp - value > 0: 
		hp -= value
	else:
		hp = 0
	#print(hp)
	

func die() -> void:
	# TODO: Add death animation
	print("Deleting enemy...")
	$AnimationPlayer.play("dead")
	queue_free()

func charge() -> void:
	target = player.global_position.x
	movement_speed = 4 * movement_speed_input
	charge_timer.start()
	$AnimationPlayer.play("charge")

func wrap_around_player() -> void:
	movement_speed = 0
	isWrapping = true
	global_position = player.global_position + Vector2(0, 25)
	$AnimationPlayer.play("attack_Draugr")

func stop_wrapping() -> void:
	movement_speed = movement_speed_input
	isWrapping = false
	playerInWrapRange = false
	wrap_cooldown_timer.start()

func check_distance_to_player() -> void:
	if player.global_position.x < left_combat_movement_limit || player.global_position.x > right_combat_movement_limit || global_position.x > right_combat_movement_limit || global_position.x < left_combat_movement_limit:
		seesPlayer = false
		if hp < max_hp && reset_hp_timer.is_stopped():
			reset_hp_timer.start()
	else: 
		seesPlayer = true
		playerInChargeRange = abs(player.global_position.x - global_position.x) > 400 && floor(player.global_position.y) == floor(global_position.y) - 25
		if wrap_cooldown_timer.is_stopped():
			playerInWrapRange = !abs(player.global_position.x - global_position.x) > 50 && floor(player.global_position.y) == floor(global_position.y) - 25

func combat_movement() -> void:
	if charge_timer.is_stopped():
		target = player.global_position.x
	
	if target > global_position.x:
		direction = 1
	elif target < global_position.x:
		direction = -1
	else:
		direction = 0
	$AnimationPlayer.play("idle_movement")

func idle_movement() -> void:
	movement_speed = movement_speed_input
	if global_position.x < target + 3 && global_position.x > target - 3:
		target = randi() % int(right_idle_movement_limit - left_idle_movement_limit) + left_idle_movement_limit

	if target > global_position.x:
		direction = 1
	elif target < global_position.x:
		direction = -1
	else:
		direction = 0
	$AnimationPlayer.play("idle_movement")
