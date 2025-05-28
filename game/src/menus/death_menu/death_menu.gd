extends Control

@export var gameplay: Node2D
@export var main_menu: Control
var a: bool = false
var b: bool = false

func _on_exit_button_down() -> void:
	b = true
	$Exit.hide()
	$Label.hide()
	$Revive.hide() 
	$Tryagain.hide()
	$RUSure.show()

func _on_tryagain_button_down() -> void:
	a = true
	$Exit.hide()
	$Label.hide()
	$Revive.hide() 
	$Tryagain.hide()
	$RUSure.show()
func _on_no_button_down() -> void:
	a = false
	b = false
	$RUSure.hide()
	$Exit.show()
	$Label.show()
	$Revive.show() 
	$Tryagain.show()

func _on_yes_button_down() -> void:
	if a == true:
		hide()
		main_menu.show()
		
	elif b == true:
		hide()
		get_tree().paused = false
		get_tree().reload_current_scene()

func _on_revive_button_down() -> void:
	gameplay.revive_player()
	hide()
	get_tree().paused = false
