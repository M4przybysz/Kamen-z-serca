extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var normal_collision: CollisionShape2D = $NormalCollision
@onready var charge_collision: CollisionShape2D = $ChargeCollision

@onready var normal_hurtbox_collision: CollisionShape2D = $NormalHurtbox/CollisionShape2D
@onready var charge_hurtbox_collision: CollisionShape2D = $ChargeHurtbox/CollisionShape2D

@onready var attack_hitbox_collision: CollisionShape2D = $AttackHitbox/CollisionShape2D

@onready var wall_detector_collision: CollisionShape2D = $WallDetector/CollisionShape2D

# Assign timers to variables
@onready var reset_hp_timer: Timer = $Timers/ResetHPTimer
@onready var charge_timer: Timer = $Timers/ChargeTimer
@onready var stun_timer: Timer = $Timers/StunTimer
@onready var idle_stay_timer: Timer = $Timers/IdleStayTimer
@onready var huh_timer: Timer = $Timers/HuhTimer			# Timer used for delaying enemy turning XD
@onready var attack_timer: Timer = $Timers/AttackTimer
@onready var turn_cooldown_timer: Timer = $Timers/TurnCooldownTimer

# Assign player to variable
@onready var player: CharacterBody2D = $"../../../Player"
#@export var player: CharacterBody2D

# Movement variables 
var target: float	# Mymmy's target (player or random point in idle range)

@export var movement_speed_input: float = 100.0 # Movement speed input
var movement_speed								# Movement speed variable that can change during the game

@export var combat_movement_range_left: int = 500	# Combat movement distance to the left
@export var combat_movement_range_right: int = 500	# Combat movement distance to the right
@export var idle_movement_range_left: int = 300		# Idle movement distance to the left
@export var idle_movement_range_right: int = 300	# Idle movement distance to the right

var starting_point: Vector2				# Mummy's starting global position
var left_combat_movement_limit: float	# Combat movement limiting point to the left
var right_combat_movement_limit: float	# Combat movement limiting point to the right
var left_idle_movement_limit: float		# Idle movement limiting point to the left
var right_idle_movement_limit: float	# Idle movement limiting point to the right

@export var knockback_force: Vector2 = Vector2(-1000, -50)	# Normal knockback force
@export var knockback_boost: Vector2 = Vector2(3, 1.5)		# Knockback boost modifiers
var knockback: Vector2 = Vector2.ZERO						# Dynamic knockback force

@export var charge_distance: float = 400.0	# Distnce from player to start charging
@export var can_push_pillars: bool = false
@export var no_charge: bool = false

# Combat variables
@export var max_hp: int = 3
var hp: int
var dmg_source_count = 0
var dmg_taken = 0
var dmg_dictionary = { # Disctionary used to determine the dmg taken by the player by the name of the enemy's attack
	"wing_attack" : 1,
	"stone_feather" : 1,
	"copper_feather" : 1,
	"bronze_feather" : 2,
	"spear" : 3,
	"spike" : 1,
	# Add more values here (format "attack_name" : damage)
}

# Dynamic playthrough variables
var state: String = "idle"
var direction = 0
var sees_player: bool = false
var player_in_attack_range: bool = false
var player_in_charge_range: bool = false
var is_wrapping: bool = false
var can_wrap: bool = false
var animation_locked: bool = false
var can_break_wall: bool = false
var can_turn: bool = true

# Random number generator
var RNG = RandomNumberGenerator.new()
var random_number: int

func _ready() -> void:
	starting_point = global_position
	left_combat_movement_limit = starting_point.x - combat_movement_range_left
	right_combat_movement_limit = starting_point.x + combat_movement_range_right
	left_idle_movement_limit = starting_point.x - idle_movement_range_left
	right_idle_movement_limit = starting_point.x + idle_movement_range_right
	hp = max_hp
	target = global_position.x
	movement_speed = movement_speed_input
	
	if can_push_pillars:
		collision_mask = 144

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if !is_on_floor():
		velocity += get_gravity() * delta
	
	# Remove dmg when falling
	if (!is_wrapping && !is_on_floor()) || !stun_timer.is_stopped():
		normal_hurtbox_collision.disabled = true
	else:
		normal_hurtbox_collision.disabled = false
	
	# Decide what to do and play animation
	state_machine()
	
	if can_turn:
		# Change direction to the target (player or random point on X axis)
		if target > global_position.x:
			direction = 1
		elif target < global_position.x:
			direction = -1
		else:
			direction = 0
	
		# Turn right or left
		flip_h()
	
	velocity.x = direction * movement_speed
	if !stun_timer.is_stopped(): velocity.x = 0
	
	velocity += knockback
	knockback = knockback.lerp(Vector2.ZERO, 0.16)
	
	move_and_slide()

#########################################
# State machine handling
#########################################
func state_machine():
	# Check death
	if hp <= 0:
		state = "die"
		if !animation_locked:
			animated_sprite.play(state)
		animation_locked = true
		return
	
	check_distance_to_player()
	check_charge()
	
	#print(state)
	
	match state:
		"idle":
			if !animation_locked:
				animated_sprite.play(state)
			
			if sees_player: state = "combat"
			elif can_break_wall && attack_timer.is_stopped(): attack()
			else:
				random_number = RNG.randi_range(0, 1)
				if random_number == 0:
					state = "idle_movement"
				else:
					state = "idle_stay"
		"idle_movement":
			if sees_player: state = "combat"
			elif can_break_wall && attack_timer.is_stopped(): attack()
			else: 
				idle_movement()
				if !animation_locked:
					animated_sprite.play(state)
		"idle_stay":
			if sees_player: 
				idle_stay_timer.stop()
				state = "combat"
			elif can_break_wall: attack()
			elif idle_stay_timer.is_stopped() && !sees_player: state = "idle"
			else: 
				idle_stay_timer.start()
				if !animation_locked:
					animated_sprite.play(state)
		"combat":
			if !sees_player: state = "idle"
			elif player_in_charge_range && !no_charge: state = "lay_down"
			elif player_in_attack_range: state = "attack"
			else: state = "combat_movement"
		"combat_movement":
			if !sees_player: state = "idle"
			elif player_in_charge_range && !no_charge: state = "lay_down"
			elif player_in_attack_range: state = "attack"
			else: 
				combat_movement()
				if !animation_locked:
					animated_sprite.play(state)
		"attack":
			if !sees_player: state = "idle"
			elif attack_timer.is_stopped(): 
				attack()
				animated_sprite.play(state)
				animation_locked = true
			else:
				state = "combat"
		"lay_down", "stand_up":
			if !animation_locked:
				animated_sprite.play(state)
				animation_locked = true
		"charge":
			if can_wrap:
				state = "wrap_around_player"
				wrap_around_player()
			elif !player_in_charge_range && charge_timer.is_stopped(): state = "stand_up"
			else: 
				charge()
				animated_sprite.play(state)
		"wrap_around_player":
			if !is_wrapping: state = "stand_up"
			else: wrap_around_player()
			animated_sprite.play(state)
		_:
			print("undefined state: ", state)
			state = "idle"

func _on_animated_sprite_2d_animation_finished() -> void:
	animation_locked = false
	match state:
		"idle_movement", "idle_stay":
			state = "idle"
		"stand_up":
			state = "combat"
		"lay_down":
			state = "charge"
		"charge":
			state = "combat_movement"
		"idle", "wrap_around_player", "attack", "combat_movement":
			pass
		"die":
			die()
		_:
			print("(animation finished) undefined state: ", state)
			state = "idle"

#########################################
# Direction change handling
#########################################
func flip_h() -> void:
	if direction > 0:
		animated_sprite.flip_h = false
		attack_hitbox_collision.position.x = 25
		wall_detector_collision.rotation_degrees = -90
	elif direction < 0:
		animated_sprite.flip_h = true
		attack_hitbox_collision.position.x = -25
		wall_detector_collision.rotation_degrees = 90
	
	can_turn = false
	turn_cooldown_timer.start()

#########################################
# Hitboxes and hurtboxes handling
#########################################
func _on_hurtbox_area_entered(area: Area2D) -> void:
	var got_charged = area.is_in_group("shield_charge")
	
	dmg_source_count += 1
	for group in dmg_dictionary:
		if area.is_in_group(group):
			dmg_taken += dmg_dictionary[group]
			if is_wrapping:
				stop_wrapping()
	if dmg_taken > 0 || got_charged:
		knockback = knockback_force
		var knockback_direction: int
		if area.global_position.x > global_position.x: knockback_direction = 1
		else: knockback_direction = -1
		knockback.x *= knockback_direction
		if got_charged: 
			stun_timer.start()
			knockback.x *= knockback_boost.x
			if is_on_floor():
				knockback.y *= knockback_boost.y
		if !stun_timer.is_stopped():
			dmg_taken *= 2
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
	#print(hp)
	reset_hp_timer.stop()

func _on_charge_timer_timeout() -> void:
	movement_speed = movement_speed_input
	charge_timer.stop()

func _on_attack_timer_timeout() -> void:
	attack_timer.stop()
	attack_hitbox_collision.disabled = true
	attack_hitbox_collision.visible = false

func _on_stun_timer_timeout() -> void:
	stun_timer.stop()

func _on_idle_stay_timer_timeout() -> void:
	idle_stay_timer.stop()

func _on_huh_timer_timeout() -> void:
	huh_timer.stop()

func _on_turn_cooldown_timer_timeout() -> void:
	turn_cooldown_timer.stop()
	can_turn = true

#########################################
# Combat handling
#########################################
func decrease_hp(value: int) -> void:
	if hp - value > 0: 
		hp -= value
	else:
		hp = 0
	#print(hp)

func die() -> void:
	#print("Deleting enemy...")
	queue_free()

func attack() -> void:
	if attack_hitbox_collision.disabled == true:
		attack_timer.start()
	attack_hitbox_collision.disabled = false
	attack_hitbox_collision.visible = true

func charge() -> void:
	target = player.global_position.x
	movement_speed = 4 * movement_speed_input
	if charge_timer.is_stopped():
		charge_timer.start()
	$AnimationPlayer.play("charge")

func wrap_around_player() -> void:
	movement_speed = 0
	is_wrapping = true
	global_position = player.global_position + Vector2(0, 25)
	$AnimationPlayer.play("attack_Draugr")

func stop_wrapping() -> void:
	movement_speed = movement_speed_input
	is_wrapping = false

#########################################
# Movement handling
#########################################
func check_distance_to_player() -> void:
	if player.global_position.x > left_combat_movement_limit && player.global_position.x < right_combat_movement_limit && global_position.x < right_combat_movement_limit && global_position.x > left_combat_movement_limit:
		sees_player = true
		player_in_charge_range = abs(player.global_position.x - global_position.x) > charge_distance && floor(player.global_position.y) > floor(global_position.y) - 50 && floor(player.global_position.y) < floor(global_position.y) + 50
		player_in_attack_range = abs(player.global_position.x - global_position.x) < 50 && floor(player.global_position.y) > floor(global_position.y) - 50 && floor(player.global_position.y) < floor(global_position.y) + 50
		can_wrap = !abs(player.global_position.x - global_position.x) > 50 && floor(player.global_position.y) > floor(global_position.y) - 50 && floor(player.global_position.y) < floor(global_position.y) + 50
	else: 
		sees_player = false
		if hp < max_hp && reset_hp_timer.is_stopped():
			reset_hp_timer.start()

func combat_movement() -> void:
	if charge_timer.is_stopped() && (huh_timer.is_stopped() || global_position.x < target + 3 && global_position.x > target - 3):
		target = player.global_position.x
		huh_timer.start()
	
	$AnimationPlayer.play("idle_movement")

func idle_movement() -> void:
	movement_speed = movement_speed_input
	if global_position.x < target + 3 && global_position.x > target - 3 || is_on_wall():
		target = randi() % int(right_idle_movement_limit - left_idle_movement_limit) + left_idle_movement_limit

	$AnimationPlayer.play("idle_movement")

#########################################
# Movement additions
#########################################
func check_charge() -> void:
	if charge_timer.is_stopped():
		charge_collision.disabled = true
		charge_hurtbox_collision.disabled = true
		normal_collision.disabled = false
		normal_hurtbox_collision.disabled = false
	else:
		normal_collision.disabled = true
		normal_hurtbox_collision.disabled = true
		charge_collision.disabled = false
		charge_hurtbox_collision.disabled = false

#########################################
# Wall detection
#########################################
func _on_wall_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("breakable_wall"):
		can_break_wall = true

func _on_wall_detector_body_exited(body: Node2D) -> void:
	if body.is_in_group("breakable_wall"):
		can_break_wall = false
