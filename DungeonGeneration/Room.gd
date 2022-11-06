extends Node2D


# Declare member variables here. Examples:
signal MovedThroughDoor_OffsetBy 
signal finished_floor


export (PackedScene) var SlimeScene = preload("res://Enemies/Slime.tscn")
export (PackedScene) var SkullScene = preload("res://Enemies/Skull.tscn")

export (PackedScene) var RockScene = preload("res://BigClutter/Rock.tscn")
export (PackedScene) var LampScene = preload("res://BigClutter/LampPost.tscn")

export (PackedScene) var Lactern = preload("res://Pedastal/Pedastal.tscn")
export (PackedScene) var BossScene = preload("res://Enemies/Boss.tscn")

export (PackedScene) var help = preload("res://BigClutter/ControlGuide.tscn")

export (PackedScene) var exit = preload("res://DungeonGeneration/FloorExit.tscn")

const map_size = Vector2(4,4) # from 0 to the value including

var room_layout
var cleared_rooms
var current_position

var current_enemies = []
var current_doors = []

enum {EMPTY, GENERIC, START, BOSS, LACTERN}

var possible_enemies
var possible_walls

var random_book_seed

var leavable = true

func generate_layout():
	# 0 empty, 1 random room, 2 spawm, 3 boss, 4 reading
	room_layout = [	[0, 0, 0, 0, 0],
					[0, 0, "hs", 0, 0],
					[0, "gd", 2, "hd", 0],
					[0, 0, "ss", 0, 0],
					[0, 0, 0, 0, 0]]
	var boss = randi()%4
	var lactern = randi()%4
	if lactern == boss:
		lactern = (lactern + 1)%4
	
	match boss:
		1:
			room_layout[0][2] = 3
		2:
			room_layout[2][0] = 3
		3:
			room_layout[2][4] = 3
		0: 
			room_layout[4][2] = 3
	
	match lactern:
		1:
			room_layout[0][2] = 4
		2:
			room_layout[2][0] = 4
		3:
			room_layout[2][4] = 4
		0: 
			room_layout[4][2] = 4
	
	current_position = Vector2(2,2)
	initialize_cleared_rooms()
	

func initialize_cleared_rooms():
	cleared_rooms = room_layout.duplicate(true)
	for i in range(map_size.x + 1):
		for j in range(map_size.y + 1):
			if typeof(cleared_rooms[i][j]) == TYPE_STRING:
				cleared_rooms[i][j] = true
			elif cleared_rooms[i][j] == 3:
				cleared_rooms[i][j] = true
			else:
				cleared_rooms[i][j] = false



# Called when the node enters the scene tree for the first time.
func _ready():
	generate_layout()
	
	generate_room()
	
	random_book_seed = randi()
	
	possible_enemies = [SlimeScene, SkullScene]
	possible_walls = [RockScene, LampScene]



func generate_room():
	
	for i in $BigClutter.get_children():
		i.queue_free()
	
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
			spawning_type[i] = true
			
	var available_spots = $SpawnLocations.get_children()
	for i in range(16):
		if spawning_type[i]:
			spawn_wall(available_spots[i].position)
		else:
			if cleared_rooms[current_position.x][current_position.y]:
				spawn_enemy(available_spots[i].position)


func spawn_wall(pos):
	var object = possible_walls[randi() % possible_walls.size()].instance()
	object.position = pos
	$BigClutter.call_deferred("add_child", object)

func spawn_enemy(pos):
	var enemy = possible_enemies[randi() % possible_enemies.size()].instance()
	enemy.position = pos
	current_enemies.append(enemy)
	$Enemies.call_deferred("add_child", enemy)
	enemy.connect("die", $RoomBG.get_parent(), "_checks_on_enemy_dying" )
	

func generate_prefab_room():
	match room_layout[current_position.x][current_position.y]:
		2:
			generate_start_room()
		3:
			generate_boss_room()
		4:
			generate_lactern_room()



func generate_start_room():
	var lac1 = Lactern.instance()
	var lac2 = Lactern.instance()
	var h = help.instance()
	
	lac1.position = $PREFABS/START/Left.position
	lac2.position = $PREFABS/START/Right.position
	
	h.position = $PREFABS/LACTERN/Position2D.position
	$BigClutter.call_deferred("add_child", lac1)
	$BigClutter.call_deferred("add_child", lac2)
	$BigClutter.call_deferred("add_child", h)
	yield(get_tree().create_timer(0.1), "timeout")  # Technically wrong but its fine
	lac1.left_spawn()
	lac2.right_spawn()
	



func generate_boss_room():
	if not cleared_rooms[current_position.x][current_position.y]:
		_checks_on_enemy_dying(null)
		return
	
	
	var boss = BossScene.instance()
	boss.position = $PREFABS/LACTERN/Position2D.position
	$Enemies.call_deferred("add_child", boss)
	current_enemies.append(boss)
	boss.connect("die", $RoomBG.get_parent(), "_checks_on_enemy_dying" )


func generate_lactern_room():
	var lac = Lactern.instance()
	lac.position = $PREFABS/LACTERN/Position2D.position
	$BigClutter.call_deferred("add_child", lac)
	yield(get_tree().create_timer(0.1), "timeout")
	lac.pick(random_book_seed)

func add_doors():
	leavable = false
	for i in $Doors.get_children():
		i.hide()
#		i.set_process(false)
	
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
	if not leavable:
		return
	
	if body.name == "Player" and current_position.x != 0 and room_layout[current_position.x - 1][current_position.y]:
		current_position.x -= 1
		generate_room()
		emit_signal("MovedThroughDoor_OffsetBy", 0, 720)


func _on_West_body_entered(body):
	if not leavable:
		return
	
	if body.name == "Player" and current_position.y != 0 and room_layout[current_position.x][current_position.y - 1]:
		current_position.y -= 1
		generate_room()
		emit_signal("MovedThroughDoor_OffsetBy", 1020, 0)

func _on_East_body_entered(body):
	if not leavable:
		return
	
	if body.name == "Player" and current_position.y != map_size.x and room_layout[current_position.x][current_position.y + 1]:
		current_position.y += 1
		generate_room()
		emit_signal("MovedThroughDoor_OffsetBy", -1020, 0)

func _on_South_body_entered(body):
	if not leavable:
		return

	if body.name == "Player" and current_position.x != map_size.y and room_layout[current_position.x + 1][current_position.y]:
		current_position.x += 1
		generate_room()
		emit_signal("MovedThroughDoor_OffsetBy", 0, -720)




func _checks_on_enemy_dying(enemy):
	current_enemies.erase(enemy)
	if current_enemies.size() == 0:
		room_emptied()



func room_emptied():
	cleared_rooms[current_position.x][current_position.y] = false
	open_doors()
	if typeof(room_layout[current_position.x][current_position.y]) == TYPE_INT and room_layout[current_position.x][current_position.y] == BOSS:
		spawn_stairs()

func spawn_stairs():
	var lac = exit.instance()
	lac.position = $PREFABS/LACTERN/Position2D.position
	$BigClutter.call_deferred("add_child", lac)
	lac.connect("body_entered", self, "remake_map")
	
func remake_map(body):
	if body.has_method("dummy_method_only_player_has"):
		emit_signal("finished_floor")
		_ready()

func open_doors():
	leavable = true
	for door in current_doors:
#		door.set_process(true)
		door.get_node("AnimatedSprite").frame = (1)
		
func nullify_casted():
	$AnimationPlayer.play("NullifyCast")

func kill_all_enemies():
	for enemy in current_enemies:
		enemy.hit_by_sword(100000, Vector2(1,1), 0, "basic")
