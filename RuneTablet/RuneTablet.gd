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

var state_changed = true

var grid
var state = [false, false, false, false, false, false, false, false, false]

var input_names = [	"rune_top_left", "rune_top_mid", "rune_top_right",
					"rune_mid_left", "rune_mid_mid", "rune_mid_right",
					"rune_bottom_left", "rune_bottom_mid", "rune_bottom_right"]


var textures = {}
var initial_scale

# Called when the node enters the scene tree for the first time.
func _ready():
	grid = [TL, TM, TR, ML, MM, MR, BL, BM, BR]
	initialize_textures()
	initial_scale = TM.scale


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if state_changed:
		draw_state()
		state_changed = false


func initialize_textures():
	textures["top_left_x"] = load("res://RuneTablet/top_left_x.png")
	textures["mid_x"]  = load("res://RuneTablet/x_mid.png")
	textures["default"]  = load("res://RuneTablet/Tile.png")



func _unhandled_input(event):
	for i in range(9):
		if Input.is_action_pressed(input_names[i]):
			state[i] = true
			state_changed = true
	if Input.is_action_just_pressed("rune_confirm"):
		emit_signal("rune_casted", rune_number())
		reset_state()

func reset_state():
	for i in range(9):
		self.state[i] = false
		state_changed = true

func rune_number():
	var result = 0
	for i in state:
		result = result << 1
		if i:
			result = result | 1
	return result





func draw_state():
	tint_pressed()
	rune_empty()
	match rune_number():
		0:
			rune_empty()
		0b101010101:
			rune_x()
		_:
			rune_default()


func tint_pressed():
	for i in range(9):
		if state[i]:
			grid[i].modulate = Color(1,0,0)
		else:
			grid[i].modulate = Color(1,1,1)

func load_texture_to_a_tile(tile, texture: String, flip_v = false, flip_h = false):
	tile.set_texture(textures[texture])
	tile.scale.x = (1 - int(flip_h)*2) * initial_scale.x
	tile.scale.y = (1 - int(flip_v)*2) * initial_scale.y


func rune_x():
	load_texture_to_a_tile(TL, "top_left_x", false, false)
	load_texture_to_a_tile(TR, "top_left_x", false, true)
	load_texture_to_a_tile(BL, "top_left_x", true, false)
	load_texture_to_a_tile(BR, "top_left_x", true, true)
	load_texture_to_a_tile(MM, "mid_x")

func rune_empty():
	for i in grid:
		load_texture_to_a_tile(i, "default")

func rune_default():
	pass















