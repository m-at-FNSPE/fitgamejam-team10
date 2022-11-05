extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$RuneTablet.connect("rune_casted", $Player, "_on_RuneTablet_rune_casted")
	$Room.connect("MovedThroughDoor_OffsetBy", $Player, "on_door_move")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
