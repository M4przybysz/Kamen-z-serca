extends CharacterBody2D

@onready var gameplay: Node2D = $".." # Assign gameplay(parent node) to variables
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D # Assign animated sprite to variables
@onready var feathers: Node2D = $Feathers

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
var last_direction = 1
var dmg_source_count = 0
var dmg_taken = 0
var active_feather: int = 0
var isGrabbing: bool = false
var isDashing: bool = false
var usesWingAttack: bool = false
var canDash: bool = true
var canBeDamaged: bool = true
var grabChange: bool = false

# Player progression variables
var level: int = 1
var max_level: int = 3
var isShieldUnlocked: bool = false

func _physics_process(delta: float) -> void:
	check_edge_grab()
	check_dash()
	
	# Add the gravity.
	if !is_on_floor(): 
		velocity += get_gravity() * delta
	
	if isGrabbing: return

	# Get direction: -1, 0, 1
	var direction = Input.get_axis("move_left", "move_right")
	if direction != 0: last_direction = direction
	
	flip_h(direction) # Flip the sprite and other things
	animate_player(direction) # Play animations
	
	# Set velocity
	if isDashing: 
		velocity.x = last_direction * movement_speed * 2
	else: 
		velocity.x = direction * movement_speed

	move_and_slide()

#########################################
# Input handling
#########################################
func _input(event: InputEvent) -> void:
	# Handle jump.
	if Input.is_action_just_pressed("jump") && (is_on_floor() || isGrabbing) && !isDashing:
		if isGrabbing:
			grabChange = true
		isGrabbing = false
		velocity.y = jump_velocity
		
	# Handle air dash and slide
	if Input.is_action_just_pressed("slide_and_air_dash") && canDash:
		isDashing = true
		canDash = false
		canBeDamaged = false
		if is_on_floor():
			normal_collision.disabled = true
			hurtbox_collision.disabled = true
			slide_collision.disabled = false
		slide_timer.start()
	
	# Handle basic attack
	if Input.is_action_just_pressed("wing_attack"):
		wing_attack_collision.disabled = false
		wing_attack_collision.visible = true
		usesWingAttack = true
		wing_attack_timer.start()
	
	# Handle range feather attacks
	if Input.is_action_just_pressed("feather_throw"):
		if !feathers.get_children()[active_feather].isOnCooldown:
			feathers.get_children()[active_feather].throw(last_direction)
	
	# Handle changing feather type
	if Input.is_action_just_pressed("change_feather_down"):
		if level == 1:
			pass
		elif level == 2:
			if active_feather == 1: active_feather -= 1
			else: active_feather += 1
		elif level == 3:
			if active_feather == 2: active_feather = 0
			else: active_feather += 1
	
	if Input.is_action_just_pressed("change_feather_up"):
		if level == 2:
			if active_feather == 0: active_feather += 1
			else: active_feather -= 1
		elif level == 3:
			if active_feather == 0: active_feather = 2
			else: active_feather -= 1
		else: 
			pass
	
	# handle spear attacks
	if Input.is_action_just_pressed("spear_attack"):
		pass
	elif Input.is_action_pressed("spear_attack"):
		pass
	
	# Handle shield use
	if Input.is_action_just_pressed("shield_use") && isShieldUnlocked:
		pass

#########################################
# Animations handling
#########################################
func animate_player(direction) -> void:
	if usesWingAttack:
		animated_sprite.play("wing_attack")
	elif !is_on_floor():
		if isDashing: pass
		elif grabChange:
			grabChange = false
			animated_sprite.play("grab_jump")
		elif isGrabbing: 
			animated_sprite.play("grab_edge")
		else:
			animated_sprite.play("mid_jump")
	elif is_on_floor():
		if isDashing:
			animated_sprite.play("slide")
		elif direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")

#########################################
# Movement additions
#########################################
func flip_h(direction):
	if direction > 0:
		animated_sprite.flip_h = false
		grab_hand.target_position.x = 100
		grab_check.target_position.x = 100
		wing_attack_collision.position.x = 75
	elif direction < 0:
		animated_sprite.flip_h = true
		grab_hand.target_position.x = -100
		grab_check.target_position.x = -100
		wing_attack_collision.position.x = -25

func check_edge_grab() -> void:
	var isFalling = velocity.y >= 0
	var checkHand = not grab_hand.is_colliding()
	var checkGrabHeight = grab_check.is_colliding()
	
	var canGrab = isFalling && checkHand && checkGrabHeight && not isGrabbing && is_on_wall_only()
	if canGrab: 
		isGrabbing = true
		animate_player(last_direction)

func check_dash() -> void:
	if !canDash && is_on_floor() && !isDashing:
		canDash = true

#########################################
# Hitboxes and hurtboxes handling
#########################################
func _on_hurtbox_area_entered(area: Area2D) -> void:
	dmg_source_count += 1
	for group in dmg_dictionary:
		if area.is_in_group(group):
			dmg_taken += dmg_dictionary[group]
	if damage_timer.is_stopped():
		gameplay.decrease_hp(floor(dmg_taken/dmg_source_count))
		damage_timer.start()

func _on_hurtbox_area_exited(area: Area2D) -> void:
	dmg_source_count -= 1
	for group in dmg_dictionary:
		if area.is_in_group(group):
			dmg_taken -= dmg_dictionary[group]

#########################################
# Timers handling
#########################################
func _on_slide_timer_timeout() -> void:
	isDashing = false
	canBeDamaged = true
	normal_collision.disabled = false
	hurtbox_collision.disabled = false
	slide_collision.disabled = true
	slide_timer.stop()

func _on_wing_attack_timer_timeout() -> void:
	wing_attack_collision.disabled = true
	wing_attack_collision.visible = false
	usesWingAttack = false
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
	print("Player ascended to level 2 and has acquired copper feathers.")

func ascend_to_level_3() -> void:
	level = 3
	gameplay.player_level_up()
	print("Player ascended to level 3 and has acquired bronze feathers.")
