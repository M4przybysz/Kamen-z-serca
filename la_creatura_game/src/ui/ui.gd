extends Control

@onready var narrator: Label = $DialogueInterface/Narrator
@onready var dynamic_dialogue_box: Label = $DialogueInterface/DynamicDialogueBox
@onready var dialogue_timer: Timer = $DialogueInterface/DialogueTimer

# HP_Interface variables
var screen_break1
var screen_break2
var screen_break3
var hp_vfx

# DialogueInterface variables
var dialogue_text: String
var dialogue_line: String

func _ready() -> void:
	# Assign HP variables
	screen_break1 = [$HP_interface/HP5,$HP_interface/HP3,$HP_interface/HP1,$HP_interface/HP_Max]
	screen_break2 = [$HP_interface/HP5,$HP_interface/HP4,$HP_interface/HP3,$HP_interface/HP1,$HP_interface/HP_Max]
	screen_break3 = [$HP_interface/HP5,$HP_interface/HP4,$HP_interface/HP3,$HP_interface/HP2,$HP_interface/HP1,$HP_interface/HP_Max]
	hp_vfx = screen_break1
	
	# Assign dialogue variables
	dialogue_text = load_text_from_file("res://assets/dialogues/example_text2.txt")
	print(dialogue_text)
	dialogue_line = get_dialogue_line("Scene1", "N:", 2)
	print(dialogue_line)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_hp(hp):
	for img in hp_vfx:
		img.visible = false
	hp_vfx[hp].visible = true

func load_text_from_file(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	return file.get_as_text()

func get_dialogue_line(story_part: String, character: String, line_number: int):
	var part_start = dialogue_text.find(story_part) + story_part.length() + 1
	var dialogue_line_start = dialogue_text.find(character, part_start) + character.length()
	var dialogue_line_end = dialogue_text.find("\n", dialogue_line_start)
	var line = dialogue_text.substr(dialogue_line_start, dialogue_line_end - dialogue_line_start)
	var line_count = 1
	
	while  line_count != line_number:
		dialogue_line_start = dialogue_text.find(character, dialogue_line_end) + character.length()
		dialogue_line_end = dialogue_text.find("\n", dialogue_line_start)
		line = dialogue_text.substr(dialogue_line_start, dialogue_line_end - dialogue_line_start)
		line_count += 1
	
	return line
