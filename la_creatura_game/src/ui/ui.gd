extends Control

var screen_break1 = [$HP_interface/HP1,$HP_interface/HP3,$HP_interface/HP5]
var screen_break2 = [$HP_interface/HP1,$HP_interface/HP3,$HP_interface/HP,$HP_interface/HP5]
var screen_break3 = [$HP_interface/HP1,$HP_interface/HP2,$HP_interface/HP3,$HP_interface/HP,$HP_interface/HP5]

var hp_vfx
func _ready() -> void:
	hp_vfx = screen_break1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func hp_up() -> void:
	
	pass
func hp_down() -> void:

	pass
