extends Control

@onready var dialogue_interface: Control = $DialogueInterface

# Narrator Dialogue properities
@onready var narrator: RichTextLabel = $DialogueInterface/Narrator/Control/RichTextLabel
@onready var narrator_placement: MarginContainer = $DialogueInterface/Narrator

# Floating Dialogue properities
@onready var dynamic_dialogue_box_text: RichTextLabel = $DialogueInterface/DynamicDiaogueBox/Control/RichTextLabel
@onready var dynamic_dialogue_box_placement: MarginContainer =$DialogueInterface/DynamicDiaogueBox

# Boss hp bar
@onready var boss_hp_bar: Control = $BossHPBar
@onready var boss_name: RichTextLabel = $BossHPBar/RichTextLabel
@onready var inner_boss_hp_bar: ColorRect = $BossHPBar/ColorRect/ColorRect

# Timers
@onready var warning_timer: Timer = $BossWarnings/WarningTimer

@export var main: Node
@export var	player: CharacterBody2D

# HP_Interface variables
var screen_break1: Array
var screen_break2: Array
var screen_break3: Array
var hp_vfx: Array
var attack_warining_vfx: Array

var throwable_icon: Array

# DialogueInterface variables
var dialogue_text: String
var dialogue_lines: Array = []
var dialogue_scene: Array = []
var dialgue_line_index: int = 0
var dialogue_on: bool = false

# Signals
signal start_oak_fight

func _ready() -> void:
	# Assign HP variables
	screen_break1 = [$HP_interface/HP5,$HP_interface/HP3,$HP_interface/HP1,$HP_interface/HP_Max]
	screen_break2 = [$HP_interface/HP5,$HP_interface/HP4,$HP_interface/HP3,$HP_interface/HP1,$HP_interface/HP_Max]
	screen_break3 = [$HP_interface/HP5,$HP_interface/HP4,$HP_interface/HP3,$HP_interface/HP2,$HP_interface/HP1,$HP_interface/HP_Max]
	hp_vfx = screen_break1
	
	throwable_icon = [$Throwables/Spear,$Throwables/Stone,$Throwables/Copper,$Throwables/Bronze]
	
	# Assign dialogue variables
	dialogue_text = load_text_from_file("res://assets/dialogues/dialogues.txt")
	dialogue_lines = get_dialogue_as_lines()
	dialogue_scene = get_scene("#Tree talk")
	
	# Assign attack warnings
	attack_warining_vfx = [$BossWarnings/WarningTop, $BossWarnings/WarningRight, $BossWarnings/WarningBottom, $BossWarnings/WarningLeft]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

#########################################
# HP interface handling
#########################################
func set_hp(hp) -> void:
	for img in hp_vfx:
		img.visible = false
	hp_vfx[hp].visible = true

func set_max_hp() -> void:
	for img in hp_vfx:
		img.visible = false

#########################################
# Throwables handling
#########################################
func change_throwable(active_feather) -> void:
	for img in throwable_icon:
		img.visible = false
	throwable_icon[active_feather].visible = true

#########################################
# Dialogue interface handling
#########################################
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
	dynamic_dialogue_box_placement.position = dynamic_dialogue_position
	narrator.text = ""
	narrator_placement.visible = false
	dynamic_dialogue_box_placement.visible = false
	dynamic_dialogue_box_text.text = ""
	dialogue_interface.visible = true
	dialgue_line_index = 0
	dialogue_on = true
	print_line()

func print_line() -> void:
	print("sex")
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
		dialogue_on = false
		player.movement_lock = false
		emit_signal("start_oak_fight")
		# main.show_end_screen() # show end screen

func _input(event: InputEvent) -> void:
	if event.is_pressed() && dialogue_on:
		narrator_placement.visible = false
		dynamic_dialogue_box_placement.visible = false
		narrator.text = ""
		dynamic_dialogue_box_text.text = ""
		print_line()

#########################################
# Boss interface handling
#########################################
func show_boss_hp_bar(b_name: String) -> void:
	boss_name.text = "[center]" + b_name + "[/center]"
	inner_boss_hp_bar.size.x = 690
	boss_hp_bar.visible = true

func hide_boss_hp_bar() -> void:
	boss_hp_bar.visible = false

func set_boss_hp(max_hp: int, hp: int) -> void:
	inner_boss_hp_bar.size.x = 690 / max_hp * hp

func boss_attack_warning(number: int) -> void:
	for img in attack_warining_vfx:
		img.visible = false
	attack_warining_vfx[number].visible = true
	warning_timer.start()

func _on_warning_timer_timeout() -> void:
	for img in attack_warining_vfx:
		img.visible = false
