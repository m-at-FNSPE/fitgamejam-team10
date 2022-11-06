extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal game_over
signal game_won

var floorNumber = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	$RuneTablet.connect("rune_casted", $Player, "_on_RuneTablet_rune_casted")
	$Room.connect("MovedThroughDoor_OffsetBy", $Player, "on_door_move")
	
	$Hud/CenterContainer2/Health.max_value = $Player.max_health
	$Hud/CenterContainer/Mana.max_value = $Player.maxmana
	
	$Player.connect("nullification", $Room , "nullify_casted")
	

func _on_Player_current_health(value):
	$Hud/CenterContainer2/Health.value = value
	if value < 0:
		emit_signal("game_over")


func _on_Player_current_mana(value):
	$Hud/CenterContainer/Mana.value = value


func _on_Completed_floor():
	floorNumber -= 1
	if floorNumber <= 0:
		emit_signal("game_won")
		
func reset():
	$Room.kill_all_enemies()
	$Room.kill_all_enemies()
	$Room.kill_all_enemies()
	$Player.mana = 0
	$Player.health = $Player.max_health
	$Room._ready()
	$Player.position = $Room/PREFABS/LACTERN/Position2D.position
	$RuneTablet.reset_state()
	floorNumber = 3
	
	
