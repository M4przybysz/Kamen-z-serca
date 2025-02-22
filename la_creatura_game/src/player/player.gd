extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var normal_collision: CollisionShape2D = $NormalCollision
@onready var slide_collision: CollisionShape2D = $SlideCollision
@onready var slide_timer: Timer = $SlideTimer
@onready var grab_hand: RayCast2D = $GrabHand
@onready var grab_check: RayCast2D = $GrabCheck

@export var movement_speed = 350.0
@export var jump_velocity = -550.0

var last_direction = 0

var isGrabbing: bool = false
var isDashing: bool = false
var canDash: bool = true

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
	
	# Flip the sprite
	if direction > 0:
		animated_sprite.flip_h = false
		grab_hand.target_position.x = 100
		grab_check.target_position.x = 100
	elif direction < 0:
		animated_sprite.flip_h = true
		grab_hand.target_position.x = -100
		grab_check.target_position.x = -100
	
	# Play animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
	
	if isDashing:
		velocity.x = last_direction * movement_speed * 2
	elif direction:
		velocity.x = direction * movement_speed
	else:
		velocity.x = move_toward(velocity.x, 0, movement_speed)

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
		if is_on_floor():
			normal_collision.disabled = true
			slide_collision.disabled = false
			animated_sprite.rotation_degrees = 90 * last_direction
		slide_timer.start()

func check_edge_grab() -> void:
	var isFalling = velocity.y >= 0
	var checkHand = not grab_hand.is_colliding()
	var checkGrabHeight = grab_check.is_colliding()
	
	var canGrab = isFalling && checkHand && checkGrabHeight && not isGrabbing && is_on_wall_only()
	
	if canGrab:
		isGrabbing = true
		animated_sprite.play("grab_edge")

func check_dash() -> void:
	if !canDash && is_on_floor() && !isDashing:
		canDash = true

func _on_slide_timer_timeout() -> void:
	isDashing = false
	normal_collision.disabled = false
	slide_collision.disabled = true
	animated_sprite.rotation_degrees = 0
	slide_timer.stop()
	slide_timer.set_wait_time(0.3)
