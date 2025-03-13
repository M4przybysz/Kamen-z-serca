extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var normal_collision: CollisionShape2D = $NormalCollision
@onready var hurtbox_collision: CollisionShape2D = $Hurtbox/CollisionShape2D
@onready var idle_range_collision: CollisionShape2D = $MovementRange/IdleRange/CollisionShape2D
@onready var combat_range_collision: CollisionShape2D = $MovementRange/CombatRange/CollisionShape2D
@onready var example_attack_collision: CollisionShape2D = $Attacks/ExampleAttack/CollisionShape2D
@onready var reset_hp_timer: Timer = $Timers/ResetHPTimer


# Movement variables 
@export var movement_speed = 300.0
@export var jump_velocity = -400.0
var starting_point: Vector2
@export var idle_distance: int = 250
@export var combat_distance: int = 500

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
var last_direction = 1
var seesPlayer = false
var playerTooFar = true
var playerInRange = false

func _ready() -> void:
	starting_point = global_position
	idle_range_collision.shape.size.x = idle_distance
	idle_range_collision.position.x = idle_distance/2 + 35
	combat_range_collision.shape.size.x = combat_distance
	combat_range_collision.position.x = combat_distance/2 + 35
	hp = max_hp

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if !is_on_floor():
		velocity += get_gravity() * delta
	
	# Decide what to do
	state_machine()
	
	# Animate enemy
	flip_h(direction)
	animated_sprite_2d.play(state)
	
	velocity.x = direction * movement_speed

	move_and_slide()

#########################################
# State machine handling
#########################################
func state_machine():
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
				pass
		"combat":
			if !seesPlayer:
				state = "idle"
			elif playerTooFar:
				state = "combat_movement"
			elif playerInRange:
				state = "attack"
		"combat_movement":
			if playerInRange:
				state = "combat"
			else:
				pass
		"attack":
			if playerTooFar:
				state = "combat"
			else:
				pass
		_:
			print("undefined state")

#########################################
# Direction change handling
#########################################
func flip_h(direction):
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

#########################################
# Combat handling
#########################################
func decrease_hp(value: int) -> void:
	if hp - value > 0: 
		hp -= value
	else:
		hp = 0
	if hp <= 0:
		# Delete enemy
		pass

func attack() -> void:
	pass

func checkDistanceTooPlayer() -> void:
	pass

func _on_idle_range_area_entered(area: Area2D) -> void:
	pass # Replace with function body.

func _on_combat_range_area_exited(area: Area2D) -> void:
	pass # Replace with function body.
