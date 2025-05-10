extends RigidBody2D

@onready var cooldown_timer: Timer = $CooldownTimer
@onready var texture: TextureRect = $TextureRect
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var hitbox_collision: CollisionShape2D = $Hitbox/CollisionShape2D

@export var player: CharacterBody2D
@export var cooldown: float = 60.0
@export var throw_strength: Vector2 = Vector2(600, -300)

var isOnCooldown: bool = false
var flight_direction: int = 1
var reset: bool = true
var platform_mode: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cooldown_timer.stop()
	visible = false
	collision.disabled = true
	hitbox_collision.disabled = true
	freeze = true

func _physics_process(delta: float) -> void:
	if reset:
		global_position = player.global_position + Vector2(0, -35)
	
	if platform_mode && !player.is_grabbing:
		global_position -= player.velocity * delta
	
	if !player.is_grabbing && !reset && !platform_mode:
		global_position -= player.velocity * delta
		apply_torque(4000 * flight_direction)

func throw(direction: int) -> void:
	if !isOnCooldown:
		reset = false
		flight_direction = direction
		rotation_degrees = 60 * flight_direction
		visible = true
		collision.disabled = false
		hitbox_collision.disabled = false
		freeze = false
		apply_impulse(throw_strength * Vector2(flight_direction, 1))
		isOnCooldown = true
		cooldown_timer.start()

func _on_cooldown_timer_timeout() -> void:
	cooldown_timer.stop()
	visible = false
	hitbox_collision.disabled = true
	collision.disabled = true
	freeze = true
	isOnCooldown = false
	reset = true

func _on_hitbox_body_entered(body: Node2D) -> void:
	if !body.is_in_group("player") && !body.is_in_group("enemy") && !platform_mode:
		platform_mode = true
		set_deferred("freeze", true)
		collision_layer = 17
		collision_mask = 17


func _on_hitbox_body_exited(body: Node2D) -> void:
	if !body.is_in_group("player") && !body.is_in_group("enemy") && platform_mode:
		platform_mode = false
		set_deferred("freeze", false)
		collision_layer = 16
		collision_mask = 16
