extends Node2D

@onready var hurtbox_collision: CollisionShape2D = $Hurtbox/CollisionShape2D
@onready var hp_regen_timer: Timer = $HPRegenTimer
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D

var max_hp: int = 5
var hp: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hp = max_hp
	hp_regen_timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
		pass

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("wing_attack") and hp > 0:
		hp -= 1
	if area.is_in_group("stone_feather") and hp > 0:
		hp -= 1
	if area.is_in_group("copper_feather") and hp > 0:
		hp -= 1
	if area.is_in_group("bronze_feather") and hp > 0:
		hp -= 3
	print(hp)
	cpu_particles_2d.emitting = true

func _on_hp_regen_timer_timeout() -> void:
	if hp < max_hp:
		hp += 1
	hp_regen_timer.stop()
	hp_regen_timer.set_wait_time(1)
	hp_regen_timer.start()
