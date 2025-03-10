extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var normal_collision: CollisionShape2D = $NormalCollision
@onready var hurtbox_collision: CollisionShape2D = $Hurtbox/CollisionShape2D
@onready var timers: Node = $Timers

@export var movement_speed = 300.0
@export var jump_velocity = -400.0

# Combat variables
var hp: int = 3
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

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if !is_on_floor():
		velocity += get_gravity() * delta
	
	# Decide what to do
	state_machine(state)
	
	# Animate enemy
	flip_h(direction)
	animate_self(state)
	
	velocity.x = direction * movement_speed

	move_and_slide()

#########################################
# State machine handling
#########################################
func state_machine(state):
	pass

#########################################
# Animation handling
#########################################
func animate_self(state):
	pass

func flip_h(direction):
	pass

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

#########################################
# Combat handling
#########################################
func decrease_hp(value: int):
	if hp - value > 0: 
		hp -= value
	else:
		hp = 0
	if hp <= 0:
		# Delete enemy
		pass
