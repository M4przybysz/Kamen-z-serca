extends CharacterBody2D

@onready var gameplay: Node2D = $".." # Assign gameplay(parent node) to variables
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D # Assign animated sprite to variables
@onready var throwables: Node2D = $Throwables

# Assign physical collision to variables
@onready var normal_collision: CollisionShape2D = $NormalCollision
@onready var slide_collision: CollisionShape2D = $SlideCollision

# Assign hitboxes and hurtboxes to variables
@onready var hurtbox_collision: CollisionShape2D = $Hurtbox/CollisionShape2D
@onready var wing_attack_collision: CollisionShape2D = $WingAttack/CollisionShape2D

# Assign raycasts to variables
@onready var grab_hand: RayCast2D = $GrabHand
@onready var grab_check: RayCast2D = $GrabCheck

# Assign timers to variables
@onready var slide_timer: Timer = $Timers/SlideTimer
@onready var wing_attack_timer: Timer = $Timers/WingAttackTimer
@onready var damage_timer: Timer = $Timers/DamageTimer

# Assign exportable variables <--- add more exportables if needed later
@export var movement_speed = 350.0
@export var jump_velocity = -550.0

# Dictionaries
var dmg_dictionary = { # Disctionary used to determine the dmg taken by the player by the name of the enemy's attack
	"enemy" : 1, 	# Test value 
	# Add more values here (format "attack_name" : damage)
}

# Dynamic playthrough variables
var state: String = "idle"
var last_direction = 1
var direction
var dmg_source_count = 0
var dmg_taken = 0
var active_feather: int = 0
var is_grabbing: bool = false
var is_dashing: bool = false
var can_dash: bool = true
var can_be_damaged: bool = true

# Player progression variables
var level: int = 1
var max_level: int = 3
var is_shield_unlocked: bool = false

func _physics_process(delta: float) -> void:
	state_machine()
	if is_grabbing: return
	
	# Add the gravity.
	if !is_on_floor(): 
		velocity += get_gravity() * delta

	# Get direction: -1, 0, 1
	direction = Input.get_axis("move_left", "move_right")
	if direction != 0: last_direction = direction
	
	flip_h() # Flip the sprite and other things
	
	# Set velocity
	if is_dashing: 
		velocity.x = last_direction * movement_speed * 2
	else: 
		velocity.x = direction * movement_speed

	move_and_slide()

#########################################
# State machine handling
#########################################
func state_machine() -> void:
	check_edge_grab()
	check_dash()
	
	print(state)
	match state:
		"idle":
			if Input.is_action_just_pressed("wing_attack"):
				state = "wing_attack"
			elif Input.is_action_just_pressed("shield_use") && is_shield_unlocked:
				state = "use_shield"
			elif Input.is_action_just_pressed("throw"):
				state = "throw"
			elif Input.is_action_just_pressed("slide_and_air_dash") && can_dash:
				state = "start_slide"
			elif Input.is_action_just_pressed("jump"):
				state = "start_jump"
			elif !is_on_floor():
				state = "mid_jump"
			elif direction != 0:
				state = "movement"
			else:
				animated_sprite.play("idle")
		"movement":
			if Input.is_action_just_pressed("wing_attack"):
				state = "wing_attack"
			elif Input.is_action_just_pressed("shield_use") && is_shield_unlocked:
				state = "use_shield"
			elif Input.is_action_just_pressed("throw"):
				state = "throw"
			elif Input.is_action_just_pressed("slide_and_air_dash") && can_dash:
				state = "start_slide"
			elif Input.is_action_just_pressed("jump"):
				state = "start_jump"
			elif !is_on_floor():
				state = "mid_jump"
			elif direction == 0:
				state = "idle"
			else:
				animated_sprite.play("movement")
		"start_jump":
			jump()
			animated_sprite.play("start_jump")
			if animated_sprite.animation_finished:
				state = "mid_jump"
		"mid_jump":
			if is_grabbing:
				print("grab")
				state = "grab_edge"
			elif Input.is_action_just_pressed("wing_attack"):
				animated_sprite.stop()
				state = "wing_attack"
			elif Input.is_action_just_pressed("shield_use") && is_shield_unlocked:
				animated_sprite.stop()
				state = "use_shield"
			elif Input.is_action_just_pressed("throw"):
				animated_sprite.stop()
				state = "throw"
			elif Input.is_action_just_pressed("slide_and_air_dash") && can_dash:
				animated_sprite.stop()
				state = "air_dash"
			elif is_on_floor():
				state = "end_jump"
			else:
				animated_sprite.play("mid_jump")
		"end_jump":
			animated_sprite.play("end_jump")
			if animated_sprite.animation_finished:
				state = "idle"
		"grab_edge":
			animated_sprite.play("grab_edge")
			if Input.is_action_just_pressed("jump"):
				animated_sprite.stop()
				state = "grab_jump"
		"grab_jump":
			jump()
			animated_sprite.play("grab_jump")
			if animated_sprite.animation_finished:
				state = "mid_jump"
		"air_dash":
			air_dash()
			animated_sprite.play("air_dash")
			if animated_sprite.animation_finished:
				state = "idle"
		"start_slide":
			slide()
			animated_sprite.play("start_slide")
			if animated_sprite.animation_finished:
				state = "mid_slide"
		"mid_slide":
			if slide_timer.is_stopped():
				animated_sprite.stop()
				state = "end_slide"
		"end_slide":
			animated_sprite.play("end_slide")
			if animated_sprite.animation_finished:
				state = "idle"
		"wing_attack":
			if wing_attack_timer.is_stopped():
				wing_attack()
			animated_sprite.play("wing_attack")
			if animated_sprite.animation_finished:
				state = "idle"
		"throw":
			throw()
			animated_sprite.play("throw")
			if animated_sprite.animation_finished:
				state = "idle"
		"use_shield":
			if Input.is_action_just_pressed("slide_and_air_dash"):
				state = "shield_charge"
			else:
				pass
		"shield_charge":
			pass
		_:
			print("undefined state")
			state = "idle"

#########################################
# Input handling
#########################################
func _input(_event: InputEvent) -> void:
	# Handle changing feather type
	if Input.is_action_just_pressed("change_throwable_down"):
		if level == 1:
			pass
		elif level == 2:
			if active_feather == 1: active_feather -= 1
			else: active_feather += 1
		elif level == 3:
			if active_feather == 2: active_feather = 0
			else: active_feather += 1
	
	if Input.is_action_just_pressed("change_throwable_up"):
		if level == 2:
			if active_feather == 0: active_feather += 1
			else: active_feather -= 1
		elif level == 3:
			if active_feather == 0: active_feather = 2
			else: active_feather -= 1
		else: 
			pass
	
	if Input.is_action_just_pressed("action"):
		pass

#########################################
# Direction change handling
#########################################
func flip_h():
	if direction > 0:
		animated_sprite.flip_h = false
		grab_hand.target_position.x = 30
		grab_check.target_position.x = 30
		wing_attack_collision.position.x = 25
	elif direction < 0:
		animated_sprite.flip_h = true
		grab_hand.target_position.x = -30
		grab_check.target_position.x = -30
		wing_attack_collision.position.x = -25

#########################################
# Movement handling
#########################################
func jump() -> void:
	is_grabbing = false
	velocity.y = jump_velocity

func air_dash() -> void:
	is_dashing = true
	can_dash = false
	can_be_damaged = false
	slide_timer.start()

func slide() -> void:
	is_dashing = true
	can_dash = false
	can_be_damaged = false
	if is_on_floor():
		normal_collision.disabled = true
		hurtbox_collision.disabled = true
		slide_collision.disabled = false
	slide_timer.start()

#########################################
# Movement additions
#########################################
func check_edge_grab() -> void:
	var isFalling = velocity.y >= 0
	var checkHand = not grab_hand.is_colliding()
	var checkGrabHeight = grab_check.is_colliding()
	
	var canGrab = isFalling && checkHand && checkGrabHeight && not is_grabbing
	if canGrab: 
		is_grabbing = true

func check_dash() -> void:
	if !can_dash && is_on_floor() && !is_dashing:
		can_dash = true

#########################################
# Combat handling
#########################################
func wing_attack() -> void:
	wing_attack_collision.disabled = false
	wing_attack_collision.visible = true
	wing_attack_timer.start()

func throw() -> void:
	if !throwables.get_children()[active_feather].isOnCooldown:
		throwables.get_children()[active_feather].throw(last_direction)

#########################################
# Hitboxes and hurtboxes handling
#########################################
func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("slowing_platform"):
		movement_speed = movement_speed/2
	else:
		dmg_source_count += 1
		for group in dmg_dictionary:
			if area.is_in_group(group):
				dmg_taken += dmg_dictionary[group]
		if damage_timer.is_stopped():
			gameplay.decrease_hp(floor(dmg_taken/dmg_source_count))
			damage_timer.start()

func _on_hurtbox_area_exited(area: Area2D) -> void:
	if area.is_in_group("slowing_platform"):
		movement_speed = movement_speed*2
	else:
		dmg_source_count -= 1
		for group in dmg_dictionary:
			if area.is_in_group(group):
				dmg_taken -= dmg_dictionary[group]

#########################################
# Timers handling
#########################################
func _on_slide_timer_timeout() -> void:
	is_dashing = false
	can_be_damaged = true
	normal_collision.disabled = false
	hurtbox_collision.disabled = false
	slide_collision.disabled = true
	slide_timer.stop()

func _on_wing_attack_timer_timeout() -> void:
	wing_attack_collision.disabled = true
	wing_attack_collision.visible = false
	wing_attack_timer.stop()

func _on_damage_timer_timeout() -> void:
	damage_timer.stop()
	if dmg_source_count > 0:
		gameplay.decrease_hp(floor(dmg_taken/dmg_source_count))
		damage_timer.start()

#########################################
# Leveling up
#########################################
func ascend_to_level_2() -> void:
	level = 2
	gameplay.player_level_up()
	print("Player ascended to level 2 and has acquired copper throwables.")

func ascend_to_level_3() -> void:
	level = 3
	gameplay.player_level_up()
	print("Player ascended to level 3 and has acquired bronze throwables.")

#########################################
# Pushable objects fix
#########################################
func _on_push_fix_body_entered(body: Node2D) -> void:
	if body.is_in_group("pushable_object"):
		body.collision_layer = 1
		body.collision_mask = 1

func _on_push_fix_body_exited(body: Node2D) -> void:
	if body.is_in_group("pushable_object"):
		body.collision_layer = 32
		body.collision_mask = 32
