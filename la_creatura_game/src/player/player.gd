extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var grab_hand: RayCast2D = $GrabHand
@onready var grab_check: RayCast2D = $GrabCheck

const SPEED = 350.0
const JUMP_VELOCITY = -550.0

var isGrabbing = false

func _physics_process(delta: float) -> void:
	check_edge_grab()
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() || isGrabbing):
		isGrabbing = false
		velocity.y = JUMP_VELOCITY
	
	if isGrabbing: return

	# Get direction: -1, 0, 1
	var direction := Input.get_axis("move_left", "move_right")
	
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
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func check_edge_grab():
	var isFalling = velocity.y >= 0
	var checkHand = not grab_hand.is_colliding()
	var checkGrabHeight = grab_check.is_colliding()
	
	var canGrab = isFalling && checkHand && checkGrabHeight && not isGrabbing && is_on_wall_only()
	
	if canGrab:
		isGrabbing = true
		animated_sprite.play("grab_edge")
