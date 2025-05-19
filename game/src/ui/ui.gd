extends Control

@onready var dialogue_interface: Control = $DialogueInterface

#Narrator Dialogue properities
@onready var narrator: RichTextLabel = $DialogueInterface/Narrator/Control/RichTextLabel
@onready var narrator_placement: MarginContainer = $DialogueInterface/Narrator

#Floating Dialogue properities
@onready var dynamic_dialogue_box_text: RichTextLabel = $DialogueInterface/DynamicDiaogueBox/Control/RichTextLabel
@onready var dynamic_dialogue_box_placement: MarginContainer =$DialogueInterface/DynamicDiaogueBox

@export var main: Node

# HP_Interface variables
var screen_break1: Array
var screen_break2: Array
var screen_break3: Array
var hp_vfx: Array

# DialogueInterface variables
var dialogue_text: String
var dialogue_lines: Array = []
var dialogue_scene: Array = []
var dialgue_line_index: int = 0

func _ready() -> void:
	# Assign HP variables
	screen_break1 = [$HP_interface/HP5,$HP_interface/HP3,$HP_interface/HP1,$HP_interface/HP_Max]
	screen_break2 = [$HP_interface/HP5,$HP_interface/HP4,$HP_interface/HP3,$HP_interface/HP1,$HP_interface/HP_Max]
	screen_break3 = [$HP_interface/HP5,$HP_interface/HP4,$HP_interface/HP3,$HP_interface/HP2,$HP_interface/HP1,$HP_interface/HP_Max]
	hp_vfx = screen_break1
	
	# Assign dialogue variables
	dialogue_text = load_text_from_file("res://assets/dialogues/dialogues.txt")
	dialogue_lines = get_dialogue_as_lines()
	dialogue_scene = get_scene("#Tree talk")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func set_hp(hp):
	for img in hp_vfx:
		img.visible = false
	hp_vfx[hp].visible = true

func set_max_hp():
	for img in hp_vfx:
		img.visible = false

func load_text_from_file(path: String) -> String:
	var file = FileAccess.open(path, FileAccess.READ)
	return file.get_as_text()

func get_dialogue_as_lines() -> Array:
	var lines = []
	var line_start = 0
	var line_end = dialogue_text.find("\n", line_start)
	var line = dialogue_text.substr(line_start, line_end - line_start).strip_edges()
	var line_count = 1
	lines.append(line)
	line_start = line_end + 1
	#print(dialogue_text.length())
	
	while true:
		line_end = dialogue_text.find("\n", line_start)
		line = dialogue_text.substr(line_start, line_end- line_start).strip_edges()
		line_count += 1
		lines.append(line)
		line_start = line_end + 1
		if line == "#####" || line_count > 50:
			break
	
	return lines

func get_scene(scene_name: String) -> Array:
	var scene = []
	var index = dialogue_lines.find(scene_name) + 1
	while true:
		if dialogue_lines[index] == "###":
			break
		scene.append(dialogue_lines[index])
		index += 1
	return scene

func print_scene(dynamic_dialogue_position:Vector2=Vector2(1320,500)) -> void:
	dynamic_dialogue_box_placement.position=dynamic_dialogue_position
	narrator.text = ""
	narrator_placement.visible = false
	dynamic_dialogue_box_placement.visible = false
	dynamic_dialogue_box_text.text = ""
	dialogue_interface.visible = true
	dialgue_line_index = 0
	print_line()

func print_line() -> void:
	if dialgue_line_index != dialogue_scene.size():
		if dialogue_scene[dialgue_line_index][0] == "N":
			narrator_placement.visible = true
			narrator.text = dialogue_scene[dialgue_line_index].substr(3, dialogue_scene[dialgue_line_index].length() - 3)
		else:
			dynamic_dialogue_box_placement.visible = true
			dynamic_dialogue_box_text.text = dialogue_scene[dialgue_line_index].substr(3, dialogue_scene[dialgue_line_index].length() - 3)
		dialgue_line_index += 1
	else:
		dialogue_interface.visible = false
		main.show_end_screen()
		# trigger end screen

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("wing_attack") or Input.is_action_just_pressed("shield_use"):
		narrator_placement.visible = false
		dynamic_dialogue_box_placement.visible = false
		narrator.text = ""
		dynamic_dialogue_box_text.text = ""
		print_line()
