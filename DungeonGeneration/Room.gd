extends Node2D


# Declare member variables here. Examples:

const map_size = Vector2(4,4) # from 0 to the value including

var room_layout

var current_position



func generate_layout():
	# 0 empty, 1 random room, 2 spawm, 3 boss, 4 reading
	room_layout = [	[3, "f", "s", "g", 4],
					[0, 0, "h", 0, 0],
					[0, 0, "f", 0, 0],
					[0, 0, "s", 0, 0],
					[0, 4, 2, 0, 0]]
	current_position = Vector2(4,2)

# Called when the node enters the scene tree for the first time.
func _ready():
	disable_prefabs()
	
	generate_layout()
	
	generate_room()

func disable_prefabs():
	for i in $PREFABS.get_children():
		i.hide()
		i.set_process(false)

func generate_room():
	match typeof(room_layout[current_position.x][current_position.y]):
		TYPE_STRING:
			generate_room_hashed()
		TYPE_INT:
			generate_prefab_room()
	add_doors()
	
	
	
	
func generate_room_hashed():
	pass


func generate_prefab_room():
	match room_layout[current_position.x][current_position.y]:
		2:
			generate_start_room()
		3:
			generate_boss_room()
		4:
			generate_lactern_room()
			
func generate_start_room():
	$PREFABS/START.show()
	$PREFABS/START.set_process(true)
	
func generate_boss_room():
	pass
	
func generate_lactern_room():
	$PREFABS/LACTERN.show()
	$PREFABS/LACTERN.set_process(true)
	
func add_doors():
	if current_position.x != 0 and room_layout[current_position.x - 1][current_position.y]:
		enable_north_door()
	if current_position.x != map_size.x and room_layout[current_position.x + 1][current_position.y]:
		enable_south_door()
	if current_position.y != 0 and room_layout[current_position.x][current_position.y - 1]:
		enable_west_door()
	if current_position.x != map_size.y and room_layout[current_position.x][current_position.y + 1]:
		enable_east_door()

func enable_north_door():
	pass
	
func enable_south_door():
	pass
	
func enable_west_door():
	pass
	
func enable_east_door():
	pass
	
