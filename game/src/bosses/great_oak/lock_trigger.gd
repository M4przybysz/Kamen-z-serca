extends Area2D

@onready var arena_lock: CollisionShape2D = $"../ArenaLock/CollisionShape2D"

var got_triggered: bool = false
var lock_arena: bool = false

func _process(_delta: float) -> void:
	if lock_arena && arena_lock.disabled:
		arena_lock.disabled = false
		arena_lock.visible = true

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") && !got_triggered:
		lock_arena = true
