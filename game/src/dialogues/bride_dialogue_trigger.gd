extends Area2D

@onready var ui: Control = $"../../../../UI/UI"
@export var dialogue_box_position:Vector2=Vector2(1320,500)
@export var one_time_trigger: bool = true
var bridephase = 0
var artificalTrig = false

var dialogue_triggered: bool = false
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") && (!one_time_trigger || (one_time_trigger && !dialogue_triggered)) or artificalTrig:
		dialogue_triggered = true
		body.movement_lock = true
		if bridephase == 0:	
			ui.dialogue_scene = ui.get_scene("#Bride1")
		if bridephase == 1:	
			ui.dialogue_scene = ui.get_scene("#Bride2")
		if bridephase == 2:	
			ui.dialogue_scene = ui.get_scene("#BridePhase1")
			ui.boss_to_start = 2
		if bridephase == 3:	
			$"../../../../UI/UI/DialogueInterface/ZakonczenieBabaWazony".show()
			ui.dialogue_scene = ui.get_scene("#BrideEnd")
		ui.print_scene(dialogue_box_position)
		bridephase +=1
