extends CharacterBody2D

@onready var gameplay: Node2D = $".." # Assign gameplay(parent node) to variables
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D # Assign animated sprite to variables

# Assign physical collision to variables
@onready var normal_collision: CollisionShape2D = $NormalCollision
@onready var slide_collision: CollisionShape2D = $SlideCollision

# Assign hitboxes and hurtboxes to variables
@onready var hurtbox_collision: CollisionShape2D = $Hurtbox/CollisionShape2D
@onready var wing_attack_collision: CollisionShape2D = $WingAttack/CollisionShape2D

# Assign grab to variables
@onready var grab_hand: RayCast2D = $GrabHand
@onready var grab_check: RayCast2D = $GrabCheck

# Assign timers to variables
@onready var slide_timer: Timer = $SlideTimer
@onready var wing_attack_timer: Timer = $WingAttack/WingAttackTimer

# Assign exportable variables <--- add more exportables if needed later
@export var movement_speed = 350.0
@export var jump_velocity = -550.0

var last_direction = 1
var isGrabbing: bool = false
var isDashing: bool = false
var canDash: bool = true
var canBeDamaged: bool = true

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

func _input(event: InputEvent) -> void:
	# Handle jump.
	if Input.is_action_just_pressed("jump") && (is_on_floor() || isGrabbing):
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
	
	if Input.is_action_just_pressed("wing_attack"):
		wing_attack_collision.disabled = false
		wing_attack_collision.visible = true
		wing_attack_timer.start()

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

func animate_player(direction) -> void: 
	if isGrabbing: 
		animated_sprite.play("grab_edge")
	elif isDashing:
		if is_on_floor(): 
			animated_sprite.rotation_degrees = 90 * last_direction # Change to animation when it's done
		else:
			pass # Change to air dashing animation when it's ready
	elif is_on_floor():
		if direction == 0: 
			animated_sprite.play("idle")
		else: 
			animated_sprite.play("run")
	else: 
		animated_sprite.play("jump")

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

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy") && canBeDamaged:
		gameplay.decrease_hp(1)

func _on_slide_timer_timeout() -> void:
	isDashing = false
	canBeDamaged = true
	normal_collision.disabled = false
	hurtbox_collision.disabled = false
	slide_collision.disabled = true
	animated_sprite.rotation_degrees = 0
	slide_timer.stop()
	slide_timer.set_wait_time(0.3)

func _on_wing_attack_timer_timeout() -> void:
	wing_attack_collision.disabled = true
	wing_attack_collision.visible = false
	wing_attack_timer.stop()
	wing_attack_timer.set_wait_time(0.5)
