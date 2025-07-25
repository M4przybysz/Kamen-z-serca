extends CharacterBody2D

@onready var gameplay: Node2D = $".." # Assign gameplay(parent node) to variables
@onready var ui: Control = $"../UI/UI"
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D # Assign animated sprite to variables
@onready var throwables: Node2D = $Throwables
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D

# Assign physical collision to variables
@onready var normal_collision: CollisionShape2D = $NormalCollision
@onready var slide_collision: CollisionShape2D = $SlideCollision
@onready var slide_fix_collision: CollisionShape2D = $SlideFix/CollisionShape2D
@onready var shield_collision: CollisionShape2D = $Shield/CollisionShape2D

# Assign hitboxes and hurtboxes to variables
@onready var hurtbox_collision: CollisionShape2D = $Hurtbox/CollisionShape2D
@onready var wing_attack_collision: CollisionShape2D = $WingAttack/CollisionShape2D
@onready var shield_charge_collision: CollisionShape2D = $Shield/Area2D/CollisionShape2D

# Assign raycasts to variables
@onready var grab_hand: RayCast2D = $GrabHand
@onready var grab_check: RayCast2D = $GrabCheck

# Assign timers to variables
@onready var slide_timer: Timer = $Timers/SlideTimer
@onready var wing_attack_timer: Timer = $Timers/WingAttackTimer
@onready var damage_timer: Timer = $Timers/DamageTimer
@onready var kojot: Timer = $Timers/Kojot

# Assign exportable variables <--- add more exportables if needed later
@export var movement_speed: float = 350.0
@export var jump_velocity: float = -550.0
@export var knockback_force: Vector2 = Vector2(-1000, -50)
@export var knockback_boost: Vector2 = Vector2(12, 5)

# Dictionaries
var dmg_dictionary = { # Disctionary used to determine the dmg taken by the player by the name of the enemy's attack
	"enemy" : 1, 	# Test value 
	"spike" : 1,
	"mummy_attack": 1,
	"short_branch" : 1, 
	"long_branch" : 1,
	"moving_root" : 1,
	"spiked_roots" : 1,
	"falling_acorn" : 1,
	# Add more values here (format "attack_name" : damage)
}

# Coyote time variables
var coyote_frames: float = 7  # How many in-air frames to allow jumping
var is_coyote: bool = false  # Track whether we're in coyote time or not
var coyote_activated: bool = false

# Dynamic playthrough variables
var rng = RandomNumberGenerator.new()
var wing_attack_rng: int
var state: String = "idle"
var last_direction = 1
var direction
var dmg_source_count = 0
var dmg_taken = 0
var active_feather: int = 1
var knockback: Vector2 = Vector2.ZERO
var is_grabbing: bool = false
var is_dashing: bool = false
var can_air_dash: bool = true
var can_be_damaged: bool = true
var can_stand_up: int = 0
var animation_locked: bool = false
var movement_lock: bool = false
var is_shield_used: bool = false
var is_charging: bool = false
var is_jumping: bool = false

# Player progression variables
var level: int = 1
var max_level: int = 3
var is_shield_unlocked: bool = false
var is_spear_unlocked: bool = false

func _ready() -> void:
	kojot.wait_time = coyote_frames / 60.0

func _physics_process(delta: float) -> void:
	state_machine()
	if is_grabbing: return
	
	# Add the gravity.
	if !is_on_floor(): velocity += get_gravity() * delta
	
	# particle :33
	if ["movement", "start_slide", "mid_slide", "end_slide", "start_jump", "end_jump"].find(state) != -1:
		cpu_particles_2d.emitting = true
	else: cpu_particles_2d.emitting = false

	
	# Get direction: -1, 0, 1
	direction = Input.get_axis("move_left", "move_right")
	if direction != 0: last_direction = direction
	
	flip_h() # Flip the sprite and other things
	
	# Set velocity
	if is_dashing: 
		velocity.x = last_direction * movement_speed * 2
	elif is_shield_used:
		velocity.x = direction * movement_speed / 2
	else: 
		velocity.x = direction * movement_speed
	
	if movement_lock:
		velocity=Vector2.ZERO + get_gravity()
	
	velocity += knockback
	knockback = knockback.lerp(Vector2.ZERO, 0.16)
	if is_on_floor():
		knockback.y = 0
	
	move_and_slide()
	
	# Check coyote 
	if !is_on_floor() && !is_jumping && !coyote_activated:
		is_coyote = true
		coyote_activated = true
		kojot.start()

#########################################
# State machine handling
#########################################
func state_machine() -> void:
	check_edge_grab()
	check_shield()
	check_air_dash()
	
	#print(state)
	
	if !movement_lock:
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
			"end_jump":
				is_jumping = false
				coyote_activated = false
				if !animation_locked:
					animated_sprite.play(state)
					animation_locked = true
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
			"use_shield":
				if !is_shield_used: state = "idle"
				elif !is_on_floor(): state = "mid_jump"
				else: animated_sprite.play(state)
			"shield_charge":
				if !is_shield_used && !is_charging: state = "idle"
				else: animated_sprite.play(state)
			"start_jump", "grab_jump", "start_slide", "end_slide", "air_dash", "wing_attack1", "wing_attack2", "throw_feather", "throw_spear":
				if !animation_locked:
					animated_sprite.play(state)
					animation_locked = true
			_:
				print("undefined state: ", state)
				state = "idle"

func _on_animated_sprite_2d_animation_finished() -> void:
	animation_locked = false
	match state:
		"start_jump", "grab_jump", "air_dash":
			state = "mid_jump"
		"end_jump", "wing_attack1", "wing_attack2", "throw_feather", "throw_spear", "end_slide":
			state = "idle"
		"use_shield", "shield_charge":
			state = "movement"
		"start_slide":
			state = "mid_slide"
		_:
			print("(animation finished) undefined state: ", state)
			state = "idle"

#########################################
# Input handling
#########################################
func _input(_event: InputEvent) -> void:
	# Handle jumping
	if Input.is_action_just_pressed("jump"):
		if (state == "idle" || state == "movement" || state == "end_slide" || state == "end_jump") && (is_on_floor() || is_coyote):
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
	
	if Input.is_action_pressed("shield_use") && is_shield_unlocked && is_on_floor(): 
		state = "use_shield"
		is_shield_used = true
		if Input.is_action_just_pressed("slide_and_air_dash"): 
			state = "shield_charge"
			shield_charge()
	
	if Input.is_action_just_released("shield_use"):
		is_shield_used = false
	
	# Handle attacks
	if Input.is_action_just_pressed("wing_attack") && wing_attack_timer.is_stopped() && (state == "idle" || state == "movement" || state == "mid_jump"): 
		wing_attack_rng = rng.randi_range(0, 1)
		if wing_attack_rng:
			state = "wing_attack1"
		else:
			state = "wing_attack2"
		wing_attack()
	
	if Input.is_action_just_pressed("throw") && !throwables.get_children()[active_feather].isOnCooldown && (state == "idle" || state == "movement" || state == "mid_jump"):
		if throwables.get_children()[active_feather].is_in_group("feather"):
			state = "throw_feather"
		elif throwables.get_children()[active_feather].is_in_group("spear") && is_spear_unlocked:
			state = "throw_spear"
		throw()
	
	# Handle changing throwables
	if Input.is_action_pressed("change_throwable_down"):
		if !is_spear_unlocked:
			return
		
		if active_feather == level: active_feather = 0
		else: active_feather += 1
		ui.change_throwable(active_feather)
	
	if Input.is_action_pressed("change_throwable_up"):
		if !is_spear_unlocked:
			return
		
		if active_feather == 0: active_feather = level
		else: active_feather -= 1
		ui.change_throwable(active_feather)
	
	# Handle spear return
	if Input.is_action_just_pressed("spear_return") && !is_grabbing:
		throwables.get_children()[0].return_to_player()
	
	# Action key can lock and unlock spear
	if Input.is_action_just_pressed("action"):
		is_spear_unlocked = !is_spear_unlocked
		is_shield_unlocked = !is_shield_unlocked

#########################################
# Direction change handling
#########################################
func flip_h():
	if direction > 0:
		animated_sprite.flip_h = false
		grab_hand.target_position.x = 30
		grab_check.target_position.x = 30
		wing_attack_collision.position.x = 25
		shield_collision.position.x = 35
		shield_charge_collision.position.x = 40
	elif direction < 0:
		animated_sprite.flip_h = true
		grab_hand.target_position.x = -30
		grab_check.target_position.x = -30
		wing_attack_collision.position.x = -25
		shield_collision.position.x = -35
		shield_charge_collision.position.x = -40

#########################################
# Movement handling
#########################################
func jump() -> void:
	is_grabbing = false
	is_jumping = true
	is_coyote = false
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
	$SFX/attack.play()

func throw() -> void:
	if !throwables.get_children()[active_feather].isOnCooldown:
		throwables.get_children()[active_feather].throw(last_direction)
		$SFX/feather.play()

func check_shield() -> void:
	if (!is_shield_used && !is_charging) || !is_on_floor():
		is_shield_used = false
		is_charging = false
		shield_collision.disabled = true
		shield_collision.visible = false
	else:
		shield_collision.disabled = false
		shield_collision.visible = true

func shield_charge() -> void:
	shield_charge_collision.disabled = false
	is_charging = true
	is_dashing = true
	can_be_damaged = false
	slide_timer.start()

#########################################
# Hitboxes and hurtboxes handling
#########################################
func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("slowing_platform") || area.is_in_group("mummy_hurtbox"):
		movement_speed = movement_speed / 2
	elif area.is_in_group("hp"):
		gameplay.increase_hp(area.get_parent().heal)
		area.get_parent().queue_free()
	elif area.is_in_group("checkpoint"):
		gameplay.increase_hp(area.get_parent().heal)
		gameplay.set_checkpoint(area.get_parent().global_position)
	else:
		var got_winded = area.is_in_group("wind")
		
		dmg_source_count += 1
		for group in dmg_dictionary:
			if area.is_in_group(group):
				dmg_taken += dmg_dictionary[group]
		if damage_timer.is_stopped():
			if dmg_taken > 0 || got_winded:
				knockback = knockback_force
				var knockback_direction: int
				$SFX/damage.play()
				if area.global_position.x > global_position.x:
					knockback_direction = 1
				else:
					knockback_direction = -1
				knockback.x *= knockback_direction
				if got_winded:
					knockback.x *= -knockback_boost.x
					if is_on_floor():
						knockback.y *= knockback_boost.y
			gameplay.decrease_hp(floor(dmg_taken/dmg_source_count))
			damage_timer.start()

func _on_hurtbox_area_exited(area: Area2D) -> void:
	if area.is_in_group("hp") || area.is_in_group("checkpoint"):
		return
	elif area.is_in_group("slowing_platform") || area.is_in_group("mummy_hurtbox"):
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
		is_charging = false
		shield_charge_collision.disabled = true
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

func _on_kojot_timeout() -> void:
	kojot.stop()
	is_coyote = false

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
