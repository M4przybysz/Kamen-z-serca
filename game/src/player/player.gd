extends CharacterBody2D

@onready var gameplay: Node2D = $".." # Assign gameplay(parent node) to variables
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D # Assign animated sprite to variables
@onready var throwables: Node2D = $Throwables

# Assign physical collision to variables
@onready var normal_collision: CollisionShape2D = $NormalCollision
@onready var slide_collision: CollisionShape2D = $SlideCollision
@onready var slide_fix_collision: CollisionShape2D = $SlideFix/CollisionShape2D

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
@export var movement_speed: float = 350.0
@export var jump_velocity: float = -575.0
@export var knockback_force: Vector2 = Vector2(-1000, -100)

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
var knockback: Vector2 = Vector2.ZERO
var is_grabbing: bool = false
var is_dashing: bool = false
var can_air_dash: bool = true
var can_be_damaged: bool = true
var can_stand_up: int = 0
var animation_locked: bool = false

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
	
	velocity += knockback
	knockback = knockback.lerp(Vector2.ZERO, 0.16)
	if is_on_floor():
		knockback.y = 0
	
	move_and_slide()

#########################################
# State machine handling
#########################################
func state_machine() -> void:
	check_edge_grab()
	check_air_dash()
	
	# print(state, " - ", animation_locked)
	
	match state:
		"idle":
			if !is_on_floor(): state = "mid_jump"
			elif direction != 0: state = "movement"
			
			animated_sprite.play(state)
		"movement":
			if !is_on_floor(): state = "mid_jump"
			elif direction == 0: state = "idle"
			
			animated_sprite.play(state)
		"start_jump":
			if is_grabbing: state = "grab_edge"
			elif !animation_locked:
				animated_sprite.play(state)
				animation_locked = true
		"mid_jump":
			if is_grabbing: state = "grab_edge"
			elif is_on_floor(): state = "end_jump"
			else: animated_sprite.play(state)
		"mid_slide":
			animated_sprite.play(state)
			if slide_timer.is_stopped():
				state = "end_slide"
		"grab_edge":
			if Input.is_action_just_pressed("jump"):
				state = "grab_jump"
				jump()
			
			if Input.is_action_pressed("look_down") && is_grabbing:
				state = "mid_jump"
				is_grabbing = false
			
			animated_sprite.play(state)
		"end_jump", "grab_jump", "start_slide", "end_slide", "air_dash", "wing_attack", "throw_feather", "throw_spear", "use_shield", "shield_charge":
			if !animation_locked:
				animated_sprite.play(state)
				animation_locked = true
		_:
			print("undefined state")
			state = "idle"

func _on_animated_sprite_2d_animation_finished() -> void:
	animation_locked = false
	match state:
		"start_jump", "grab_jump", "air_dash":
			state = "mid_jump"
		"end_jump", "wing_attack", "throw_feather", "throw_spear", "end_slide":
			state = "idle"
		"start_slide":
			state = "mid_slide"
		_:
			pass

#########################################
# Input handling
#########################################
func _input(_event: InputEvent) -> void:
	# Handle jumping
	if Input.is_action_just_pressed("jump"):
		if state == "idle" || state == "movement" || state == "end_slide" || state == "end_jump":
			state = "start_jump"
			jump()
	
	# Handle dashing and sliding
	if Input.is_action_just_pressed("slide_and_air_dash"):
		if state == "mid_jump" && can_air_dash:
			state = "air_dash"
			air_dash()
		if state == "idle" || state == "movement" || state == "end_slide" || state == "end_jump":
			state = "start_slide"
			slide()
	
	if Input.is_action_just_pressed("shield_use") && is_shield_unlocked: 
		if Input.is_action_just_pressed("slide_and_air_dash"): 
			state = "shield_charge"
		else:
			state = "use_shield"
	
	# Handle attacks
	if Input.is_action_just_pressed("wing_attack") && wing_attack_timer.is_stopped() && (state == "idle" || state == "movement" || state == "mid_jump"): 
		state = "wing_attack"
		wing_attack()
	
	if Input.is_action_just_pressed("throw") && !throwables.get_children()[active_feather].isOnCooldown && (state == "idle" || state == "movement" || state == "mid_jump"):
		if throwables.get_children()[active_feather].is_in_group("feather"):
			state = "throw_feather"
		elif throwables.get_children()[active_feather].is_in_group("spear"):
			state = "throw_spear"
		throw()
	
	# Handle changing throwables
	if Input.is_action_pressed("change_throwable_down"):
		if active_feather == level: active_feather = 0
		else: active_feather += 1
	
	if Input.is_action_pressed("change_throwable_up"):
		if active_feather == 0: active_feather = level
		else: active_feather -= 1
	
	if Input.is_action_just_pressed("spear_return") && !is_grabbing:
		throwables.get_children()[0].return_to_player()
	
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
	can_air_dash = false
	can_be_damaged = false
	slide_timer.start()

func slide(time: float = 0.5) -> void:
	is_dashing = true
	can_be_damaged = false
	if is_on_floor():
		slide_collision.disabled = false
		slide_fix_collision.disabled = false
		normal_collision.disabled = true
		hurtbox_collision.disabled = true
	slide_timer.wait_time = time
	slide_timer.start()

#########################################
# Movement additions
#########################################
func check_edge_grab() -> void:
	var isFalling = velocity.y >= 0
	var checkHand = not grab_hand.is_colliding()
	var checkGrabHeight = grab_check.is_colliding()
	
	var canGrab = isFalling && checkHand && checkGrabHeight && !is_grabbing && (state == "start_jump" || state == "mid_jump") 
	if canGrab: 
		is_grabbing = true

func check_air_dash() -> void:
	if (is_on_floor() || is_grabbing) && !can_air_dash:
		can_air_dash = true

#########################################
# Combat handling
#########################################
func wing_attack() -> void:
	if wing_attack_collision.disabled == true:
		wing_attack_timer.start()
	wing_attack_collision.disabled = false
	wing_attack_collision.visible = true

func throw() -> void:
	if !throwables.get_children()[active_feather].isOnCooldown:
		throwables.get_children()[active_feather].throw(last_direction)

#########################################
# Hitboxes and hurtboxes handling
#########################################
func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("slowing_platform"):
		movement_speed = movement_speed / 2
	else:
		dmg_source_count += 1
		for group in dmg_dictionary:
			if area.is_in_group(group):
				dmg_taken += dmg_dictionary[group]
		if damage_timer.is_stopped():
			gameplay.decrease_hp(floor(dmg_taken/dmg_source_count))
			knockback = knockback_force
			var knockback_direction: int
			if area.global_position.x > global_position.x:
				knockback_direction = 1
			else:
				knockback_direction = -1
			knockback.x *= knockback_direction
			damage_timer.start()

func _on_hurtbox_area_exited(area: Area2D) -> void:
	if area.is_in_group("slowing_platform"):
		movement_speed = movement_speed * 2
	else:
		dmg_source_count -= 1
		for group in dmg_dictionary:
			if area.is_in_group(group):
				dmg_taken -= dmg_dictionary[group]

#########################################
# Timers handling
#########################################
func _on_slide_timer_timeout() -> void:
	slide_timer.stop()
	if can_stand_up == 0:
		is_dashing = false
		can_be_damaged = true
		normal_collision.disabled = false
		hurtbox_collision.disabled = false
		slide_collision.disabled = true
		slide_fix_collision.disabled = true
	else:
		slide(0.2)

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
		body.collision_layer = 97
		body.collision_mask = 97

func _on_push_fix_body_exited(body: Node2D) -> void:
	if body.is_in_group("pushable_object"):
		body.collision_layer = 96
		body.collision_mask = 96

#########################################
# Slide fix
#########################################
func _on_slide_fix_body_entered(body: Node2D) -> void:
	if !body.is_in_group("player") && !body.is_in_group("responsive_platform"):
		can_stand_up += 1

func _on_slide_fix_body_exited(body: Node2D) -> void:
	if !body.is_in_group("player") || body.is_in_group("responsive_platform"):
		can_stand_up -= 1
