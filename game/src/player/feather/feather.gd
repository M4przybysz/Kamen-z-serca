extends Node2D

@onready var player: CharacterBody2D = $"../.."
@onready var flight_timer: Timer = $FlightTimer
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var hitbox_collision: CollisionShape2D = $Hitbox/CollisionShape2D

@export var flight_time: float = 1.0
@export var cooldown: float = 2.0
@export var speed: int = 550

var isThrown: bool = false
var isOnCooldown: bool = false
var flight_direction: int = 1
var reset = false

func _ready() -> void:
	flight_timer.wait_time = flight_time
	cooldown_timer.wait_time = cooldown
	visible = false
	hitbox_collision.disabled = true

func _process(delta: float) -> void:
	if isThrown:
		global_position.x += (flight_direction * speed - player.velocity.x) * delta
		global_position.y -= player.velocity.y * delta
	
	if reset:
		global_position = player.global_position
		isThrown = false
		visible = false
		hitbox_collision.disabled = true
		reset = false

func throw(direction: int) -> void:
	if isOnCooldown:
		return
		
	flight_direction = direction
	global_position = player.global_position  # Start from player position
	visible = true
	hitbox_collision.disabled = false
	isThrown = true
	isOnCooldown = true
	flight_timer.start()
	cooldown_timer.start()

func _on_flight_timer_timeout() -> void:
	flight_timer.stop()
	reset = true

func _on_cooldown_timer_timeout() -> void:
	cooldown_timer.stop()
	isOnCooldown = false

func _on_hitbox_body_entered(body: Node2D) -> void:
	if !body.is_in_group("player"):
		flight_timer.stop()
		reset = true
