extends Area2D

@onready var ui: Control = $"../../../../UI/UI"
@export var dialogue_box_position:Vector2=Vector2(1320,500)
@export var one_time_trigger: bool = true
var bridephase = 0

var dialogue_triggered: bool = false
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") && (!one_time_trigger || (one_time_trigger && !dialogue_triggered)):
		dialogue_triggered = true
		body.movement_lock = true
		if bridephase == 1 or bridephase == 2:	
			ui.koniec.volume_db = 0
			ui.Oblubienica_po.volume_db = -80
			ui.dialogue_scene = ui.get_scene("#EndingNeutral")
			ui.boss_to_start = 3
		if bridephase == 3:	
			$"../../../../UI/UI/DialogueInterface/ZakonczeniaWedrowiec".show
			ui.dialogue_scene = ui.get_scene("#EndingGood")
		ui.print_scene(dialogue_box_position)
		bridephase +=1
