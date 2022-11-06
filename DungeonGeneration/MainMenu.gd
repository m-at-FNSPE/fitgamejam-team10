extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal start_game
signal credits

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_NewGame_pressed():
	emit_signal("start_game")


func _on_Exit_pressed():
	get_tree().quit()


func _on_Credits_pressed():
	emit_signal("credits")
