extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal rune_casted



onready var TL = $Grid/TL
onready var TM = $Grid/TM
onready var TR = $Grid/TR
onready var ML = $Grid/ML
onready var MM = $Grid/MM
onready var MR = $Grid/MR
onready var BL = $Grid/BL
onready var BM = $Grid/BM
onready var BR = $Grid/BR


var grid
var state = [false, false, false, false, false, false, false, false, false]

var input_names = [	"rune_top_left", "rune_top_mid", "rune_top_right",
					"rune_mid_left", "rune_mid_mid", "rune_mid_right",
					"rune_bottom_left", "rune_bottom_mid", "rune_bottom_right"]

# Called when the node enters the scene tree for the first time.
func _ready():
	grid = [TL, TM, TR, ML, MM, MR, BL, BM, BR]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	tint_pressed()

func reset_combination():
	print_debug(rune_number())
	for i in range(9):
		self.state[i] = false

func tint_pressed():
	for i in range(9):
		if state[i]:
			grid[i].modulate = Color(1,0,0)
		else:
			grid[i].modulate = Color(1,1,1)


func _unhandled_input(event):
	for i in range(9):
		if Input.is_action_pressed(input_names[i]):
			state[i] = true
	if Input.is_action_just_pressed("rune_confirm"):
		emit_signal("rune_casted", rune_number())
		reset_combination()


func rune_number():
	var result = 0
	for i in state:
		result = result << 1
		if i:
			result = result | 1
	return result
