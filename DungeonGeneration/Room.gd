extends Node2D


# Declare member variables here. Examples:
signal MovedThroughDoor_OffsetBy 



export (PackedScene) var SlimeScene = preload("res://Enemies/Slime.tscn")
export (PackedScene) var SkullScene = preload("res://Enemies/Skull.tscn")


const map_size = Vector2(4,4) # from 0 to the value including

var room_layout
var cleared_rooms
var current_position

var current_enemies = []
var current_doors = []

enum {EMPTY, GENERIC, START, BOSS, LACTERN}

var possible_enemies

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
	
	possible_enemies = [SlimeScene, SkullScene]

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
	var h = room_layout[current_position.x][current_position.y].sha1_buffer()
	h = (("0x" + h.hex_encode().substr(5,15)).hex_to_int())
	var spawning_type = [	false, true, true, false,  # true for walls, false for mobs
							true, false, false, true,
							true, false, false, true,
							false, true, true, false]
	for i in range(16):
		if (1 << i) & h == 0:
			print(i)
			spawning_type[i] = true
			print(spawning_type)
			
	var available_spots = $SpawnLocations.get_children()
	for i in range(16):
		if available_spots[i]:
			spawn_wall(available_spots[i].position)
		else:
			spawn_enemy(available_spots[i].position)


func spawn_wall(pos):
	var enemy = possible_enemies[randi() % possible_enemies.size()].instance()
	enemy.position = pos
	current_enemies.append(enemy)
	$Enemies.call_deferred("add_child", enemy)

func spawn_enemy(pos):
	print(pos)
	var enemy = possible_enemies[randi() % possible_enemies.size()].instance()
	enemy.position = pos
	current_enemies.append(enemy)
	$Enemies.add_child(enemy)
	

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
		i.monitoring = false
		i.set_process(false)
	
	current_doors = []
	if current_position.x != 0 and room_layout[current_position.x - 1][current_position.y]:
		current_doors.append($Doors/North)
	if current_position.x != map_size.x and room_layout[current_position.x + 1][current_position.y]:
		current_doors.append($Doors/South)
	if current_position.y != 0 and room_layout[current_position.x][current_position.y - 1]:
		current_doors.append($Doors/West)
	if current_position.y != map_size.y and room_layout[current_position.x][current_position.y + 1]:
		current_doors.append($Doors/East)
		
	for door in current_doors:
		door.show()
		door.get_node("AnimatedSprite").frame = 0
		
	_checks_on_enemy_dying(null)


func _on_North_body_entered(body):
	if body.name == "Player" and current_position.x != 0 and room_layout[current_position.x - 1][current_position.y]:
		current_position.x -= 1
		generate_room()
		emit_signal("MovedThroughDoor_OffsetBy", 0, 720)


func _on_West_body_entered(body):
	if body.name == "Player" and current_position.y != 0 and room_layout[current_position.x][current_position.y - 1]:
		current_position.y -= 1
		generate_room()
		emit_signal("MovedThroughDoor_OffsetBy", 1020, 0)

func _on_East_body_entered(body):
	if body.name == "Player" and current_position.y != map_size.x and room_layout[current_position.x][current_position.y + 1]:
		current_position.y += 1
		generate_room()
		emit_signal("MovedThroughDoor_OffsetBy", -1020, 0)

func _on_South_body_entered(body):
	if body.name == "Player" and current_position.x != map_size.y and room_layout[current_position.x + 1][current_position.y]:
		current_position.x += 1
		generate_room()
		emit_signal("MovedThroughDoor_OffsetBy", 0, -720)




func _checks_on_enemy_dying(enemy):
	current_enemies.erase(enemy)
	if current_enemies.size() == 0:
		room_emptied()



func room_emptied():
	open_doors()
	if typeof(room_layout[current_position.x][current_position.y]) == TYPE_INT and room_layout[current_position.x][current_position.y] == BOSS:
		spawn_stairs()

func spawn_stairs():
	pass

func open_doors():
	for door in current_doors:
		door.set_process(true)
		door.get_node("AnimatedSprite").frame = (1)
		door.monitoring = true

