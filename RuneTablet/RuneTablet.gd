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
	textures["top_left_x"] = preload("res://RuneTablet/top_left_x.png")
	textures["mid_x"]  = preload("res://RuneTablet/x_mid.png")
	textures["default"]  = preload("res://RuneTablet/Tile.png")
	textures["default_circle"]  = preload("res://RuneTablet/circle.png")
	textures["circle_corner"]  = preload("res://RuneTablet/circle_big_tl_corner.png")
	textures["circle_top"]  = preload("res://RuneTablet/circle_big_top.png")
	textures["default_corner"]  = preload("res://RuneTablet/default_corner.png")
	textures["default_side"]  = preload("res://RuneTablet/default_side.png")
	textures["default_top"]  = preload("res://RuneTablet/default_top.png")
	
	textures["default_1_texture"]  = preload("res://RuneTablet/1_neighbor.png")
	textures["default_3_texture"]  = preload("res://RuneTablet/3_neighbor.png")
	textures["default_4_texture"]  = preload("res://RuneTablet/4_neighbor.png")
	textures["default_side_texture"]  = preload("res://RuneTablet/side.png")

func _unhandled_input(_event):
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


func how_many_cells_active():
	var result = 0
	for i in state:
		if i:
			result += 1
	return result



func draw_state():
	tint_pressed()
	rune_empty()
	
	match rune_number():
		0:
			rune_empty()
		0b101010101:
			rune_x()
		0b111101111:
			rune_circle()
		_:
			rune_default()


func tint_pressed():
	for i in range(9):
		if state[i]:
			grid[i].modulate = Color(1,0.6,0.6)
		else:
			grid[i].modulate = Color(1,1,1)

func load_texture_to_a_tile(tile, texture: String, flip_v = false, flip_h = false, rotate_half_pi = false):
	tile.set_texture(textures[texture])
	tile.scale.x = (1 - int(flip_h)*2) * initial_scale.x
	tile.scale.y = (1 - int(flip_v)*2) * initial_scale.y
	tile.set_rotation(int(rotate_half_pi) * PI/2)
	
func identical_corners(texture: String):
	load_texture_to_a_tile(TL, texture, false, false)
	load_texture_to_a_tile(TR, texture, false, true)
	load_texture_to_a_tile(BL, texture, true, false)
	load_texture_to_a_tile(BR, texture, true, true)

func rune_x():
	identical_corners("top_left_x")
	load_texture_to_a_tile(MM, "mid_x")
	
func rune_circle():
	identical_corners("circle_corner")
	
	load_texture_to_a_tile(TM, "circle_top", false, false)
	load_texture_to_a_tile(MR, "circle_top", false, false, true)
	load_texture_to_a_tile(ML, "circle_top", true, false, true)
	load_texture_to_a_tile(BM, "circle_top", true)

func rune_empty():
	for i in grid:
		load_texture_to_a_tile(i, "default")



func check_left(i):
	if i != 0 and i != 3 and i != 6 and state[i-1]:
		return true
	return false

func check_right(i):
	if  i != 2 and i != 5 and i != 8 and state[i+1]:
		return true
	return false
	
	
func check_top(i):
	if i != 0 and i != 1 and i != 2 and state[i-3]:
		return true
	return false
	
func check_bottom(i):
	if i != 6 and i != 7 and i != 8 and state[i+3]:
		return true
	return false



func rune_default():
	for i in range(9):
		var tile = grid[i]
		
		if not state[i]:
			load_texture_to_a_tile(tile, "default")
			continue
		
		if i == 4 and state[1] and state[3] and state[5] and state[7]:
			load_texture_to_a_tile(tile, random_4_neighbors_texture())

		elif check_bottom(i) and check_left(i) and check_right(i):
			load_texture_to_a_tile(tile, random_3_neighbors_texture())
		elif check_top(i) and check_left(i) and check_right(i):
			load_texture_to_a_tile(tile, random_3_neighbors_texture(), true)
		elif check_bottom(i) and check_left(i) and check_top(i):
			load_texture_to_a_tile(tile, random_3_neighbors_texture(), false, true, true)
		elif check_bottom(i) and check_top(i) and check_right(i):
			load_texture_to_a_tile(tile, random_3_neighbors_texture(), true, false, true)

		elif check_bottom(i) and check_right(i):
			load_texture_to_a_tile(tile, random_corner_neighbors_texture())
		elif check_top(i) and check_right(i):
			load_texture_to_a_tile(tile, random_corner_neighbors_texture(), true)
		elif check_bottom(i) and check_left(i):
			load_texture_to_a_tile(tile, random_corner_neighbors_texture(), false, true, false)
		elif check_top(i) and check_left(i):
			load_texture_to_a_tile(tile, random_corner_neighbors_texture(), true, true)

		elif check_bottom(i) and check_top(i):
			load_texture_to_a_tile(tile, random_straight_neighbors_texture())
		elif check_left(i) and check_right(i):
			load_texture_to_a_tile(tile, random_straight_neighbors_texture(), false, false, true)

		elif check_right(i):
			load_texture_to_a_tile(tile, random_1_texture())
		elif check_left(i):
			load_texture_to_a_tile(tile, random_1_texture(), false, true)
		elif check_top(i):
			load_texture_to_a_tile(tile, random_1_texture(), false, true, true)
		elif check_bottom(i):
			load_texture_to_a_tile(tile, random_1_texture(), false, false, true)

		else:
			load_texture_to_a_tile(tile, no_neighbors_texture())


func random_4_neighbors_texture():
	var options = ["default_4_texture"]
	return options[randi() % options.size()]
	
	
func random_3_neighbors_texture():
	var options = ["default_3_texture"]
	return options[randi() % options.size()]
	
	
func random_corner_neighbors_texture():
	var options = ["default_corner"]
	return options[randi() % options.size()]
	
	
func random_straight_neighbors_texture():
	var options = ["default_side"]
	return options[randi() % options.size()]
	
func random_1_texture():
	var options = ["default_1_texture"]
	return options[randi() % options.size()]
	
func no_neighbors_texture():
	var options = ["default_circle"]
	return options[randi() % options.size()]
