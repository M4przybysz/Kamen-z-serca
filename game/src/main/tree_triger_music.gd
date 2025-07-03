extends Area2D
@onready var drzewo_spokoj: AudioStreamPlayer = $"../DrzewoSpokój"
@onready var las_walka: AudioStreamPlayer = $"../LasWalka1"
@onready var las_spokoj: AudioStreamPlayer = $"../LasSpokoj1"
@onready var drzewo_walka: AudioStreamPlayer = $"../DrzewoWalka"

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		las_spokoj.volume_db = -80
		las_walka.volume_db = -80
		drzewo_walka.volume_db = -80
		drzewo_spokoj.volume_db = 0
