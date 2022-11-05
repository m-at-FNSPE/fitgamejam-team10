extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


var room_layout

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func generate_layout():
	# 0 empty, 1 random room, 2 spawm, 3 boss, 4 reading
	room_layout = [	[3, 1, 1, 1, 4],
					[0, 0, 1, 0, 0],
					[0, 0, 1, 0, 0],
					[0, 0, 1, 0, 0],
					[0, 0, 2, 0, 0]]


func instanciate_rooms():
	pass
