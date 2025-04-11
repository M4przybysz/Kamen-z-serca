extends Node2D

@onready var player: CharacterBody2D = $"../.."
@onready var flight_timer: Timer = $FlightTimer
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var hitbox_collision: CollisionShape2D = $Hitbox/CollisionShape2D

@export var flight_time:  = 1
@export var cooldown: float = 2
@export var speed: int = 550

var isThrown: bool = false
var isOnCooldown: bool = false
var flight_direction = 1

func _ready() -> void:
	flight_timer.wait_time = flight_time
	cooldown_timer.wait_time = cooldown

func _process(delta: float) -> void:
	if !isThrown:
		pass
	else:
		global_position.x += (flight_direction * speed - player.velocity.x) * delta
		global_position.y -= player.velocity.y * delta

func throw(direction):
	flight_direction = direction
	visible = true
	hitbox_collision.disabled = false
	isThrown = true
	isOnCooldown = true
	flight_timer.start()
	cooldown_timer.start()

func _on_flight_timer_timeout() -> void:
	isThrown = false
	visible = false
	hitbox_collision.disabled = true
	global_position = player.global_position
	flight_timer.stop()
	flight_timer.wait_time = flight_time

func _on_cooldown_timer_timeout() -> void:
	isOnCooldown = false
	cooldown_timer.stop()
	cooldown_timer.wait_time = cooldown
