extends StaticBody2D

@export var hp: int = 1

var dmg_taken: int = 0
var dmg_dictionary = {
	"wing_attack" : 1,
	"stone_feather" : 1,
	"copper_feather" : 1,
	"bronze_feather" : 2,
	"spear" : 1,
}

func _on_hurtbox_area_entered(area: Area2D) -> void:
	for group in dmg_dictionary:
		if area.is_in_group(group):
			dmg_taken += dmg_dictionary[group]
	hp -= dmg_taken
	if hp <= 0:
		print("Wall destroyed")
		queue_free()
