extends Control

var screen_break1
var screen_break2
var screen_break3
var hp_vfx

func _ready() -> void:
	screen_break1 = [$HP_interface/HP5,$HP_interface/HP3,$HP_interface/HP1,$HP_interface/HP_Max]
	screen_break2 = [$HP_interface/HP5,$HP_interface/HP4,$HP_interface/HP3,$HP_interface/HP1,$HP_interface/HP_Max]
	screen_break3 = [$HP_interface/HP5,$HP_interface/HP4,$HP_interface/HP3,$HP_interface/HP2,$HP_interface/HP1,$HP_interface/HP_Max]
	hp_vfx = screen_break1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func set_hp(hp):
	for img in hp_vfx:
		img.visible = false
	hp_vfx[hp].visible = true
	
