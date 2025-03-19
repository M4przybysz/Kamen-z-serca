extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var normal_collision: CollisionShape2D = $NormalCollision
@onready var hurtbox_collision: CollisionShape2D = $Hurtbox/CollisionShape2D
@onready var example_attack_collision: CollisionShape2D = $Attacks/ExampleAttack/CollisionShape2D
@onready var reset_hp_timer: Timer = $Timers/ResetHPTimer
@onready var attack_timer: Timer = $Timers/AttackTimer

@onready var player: CharacterBody2D = $"../../../Player"


# Movement variables 
@export var movement_speed = 150.0
var starting_point: Vector2
var left_movement_limit: float
var right_movement_limit: float
var target: float
@export var movement_range_left: int = 250
@export var movement_range_right: int = 250

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

func _ready() -> void:
	starting_point = global_position
	left_movement_limit = starting_point.x - movement_range_left
	right_movement_limit = starting_point.x + movement_range_right
	hp = max_hp
	target = global_position.x

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
			elif !playerInRange:
				state = "combat_movement"
			elif playerInRange:
				state = "attack"
		"combat_movement":
			if playerInRange || !seesPlayer:
				state = "combat"
			else:
				combat_movement()
		"attack":
			if !playerInRange:
				state = "combat"
			else:
				attack()
		_:
			print("undefined state")

#########################################
# Direction change handling
#########################################
func flip_h():
	if direction > 0:
		animated_sprite_2d.flip_h = false
		example_attack_collision.position.x = 45
	elif direction < 0:
		animated_sprite_2d.flip_h = true
		example_attack_collision.position.x = -45

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

func _on_attack_timer_timeout() -> void:
	example_attack_collision.visible = false
	example_attack_collision.disabled = true
	attack_timer.stop()

#########################################
# Combat handling
#########################################
func decrease_hp(value: int) -> void:
	if hp - value > 0: 
		hp -= value
	else:
		hp = 0
	print(hp)
	if hp <= 0:
		# TODO: Add death animation
		print("Deleting enemy...")
		queue_free()

func attack() -> void:
	example_attack_collision.visible = true
	example_attack_collision.disabled = false
	attack_timer.start()

func check_distance_to_player() -> void:
	if player.global_position.x < left_movement_limit || player.global_position.x > right_movement_limit:
		seesPlayer = false
		if hp < max_hp && reset_hp_timer.is_stopped():
			reset_hp_timer.start()
	else: 
		seesPlayer = true
		if abs(player.global_position.x - global_position.x) > 100:
			playerInRange = false
		else:
			playerInRange = true
		

func combat_movement() -> void:
	target = player.global_position.x
	
	if target > global_position.x:
		direction = 1
	elif target < global_position.x:
		direction = -1
	else:
		direction = 0

func idle_movement() -> void:
	if global_position.x < target + 3 && global_position.x > target - 3:
		target = randi() % int(right_movement_limit - left_movement_limit) + left_movement_limit

	if target > global_position.x:
		direction = 1
	elif target < global_position.x:
		direction = -1
	else:
		direction = 0
