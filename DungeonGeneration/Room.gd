extends Node2D


# Declare member variables here. Examples:
signal MovedThroughDoor_OffsetBy 


const map_size = Vector2(4,4) # from 0 to the value including

var room_layout
var cleared_rooms
var current_position



func generate_layout():
	# 0 empty, 1 random room, 2 spawm, 3 boss, 4 reading
	room_layout = [	[3, "sf", "ss", "gs", 4],
					[0, 0, "hs", 0, 0],
					[0, 0, "fs", 0, 0],
					[0, 0, "ss", 0, 0],
					[0, 4, 2, "s", 0]]
	current_position = Vector2(4,2)
	initialize_cleared_rooms()

func initialize_cleared_rooms():
	cleared_rooms = room_layout.duplicate(true)
	for i in range(map_size.x + 1):
		for j in range(map_size.y + 1):
			if typeof(cleared_rooms[i][j]) == TYPE_STRING:
				cleared_rooms[i][j] = true
			else:
				cleared_rooms[i][j] = false



# Called when the node enters the scene tree for the first time.
func _ready():
	generate_layout()
	
	generate_room()

func disable_prefabs():
	for i in $PREFABS.get_children():
		i.hide()
		i.set_process(false)

func generate_room():
	disable_prefabs()
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
	for i in $Doors.get_children():
		i.hide()
		i.set_process(false)

		
		
	if current_position.x != 0 and room_layout[current_position.x - 1][current_position.y]:
		enable_north_door()
	if current_position.x != map_size.x and room_layout[current_position.x + 1][current_position.y]:
		enable_south_door()
	if current_position.y != 0 and room_layout[current_position.x][current_position.y - 1]:
		enable_west_door()
	if current_position.y != map_size.y and room_layout[current_position.x][current_position.y + 1]:
		enable_east_door()


func enable_north_door():
	$Doors/North.show()
	$Doors/North.set_process(true)


	
func enable_south_door():
	$Doors/South.show()
	$Doors/South.set_process(true)


	
func enable_west_door():
	$Doors/West.show()
	$Doors/West.set_process(true)


func enable_east_door():
	$Doors/East.show()
	$Doors/East.set_process(true)
	


func _on_North_body_entered(body):
	if body.name == "Player" and current_position.x != 0 and room_layout[current_position.x - 1][current_position.y]:
		current_position.x -= 1
		generate_room()
		emit_signal("MovedThroughDoor_OffsetBy", 0, 750)


func _on_West_body_entered(body):
	if body.name == "Player" and current_position.y != 0 and room_layout[current_position.x][current_position.y - 1]:
		current_position.y -= 1
		generate_room()
		emit_signal("MovedThroughDoor_OffsetBy", 1050, 0)

func _on_East_body_entered(body):
	if body.name == "Player" and current_position.y != map_size.x and room_layout[current_position.x][current_position.y + 1]:
		current_position.y += 1
		generate_room()
		emit_signal("MovedThroughDoor_OffsetBy", -1050, 0)

func _on_South_body_entered(body):
	if body.name == "Player" and current_position.x != map_size.y and room_layout[current_position.x + 1][current_position.y]:
		current_position.x += 1
		generate_room()
		emit_signal("MovedThroughDoor_OffsetBy", 0, -750)
