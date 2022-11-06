extends Node

export(PackedScene) var credits = preload("res://DungeonGeneration/Credits.tscn")
export(PackedScene) var end = preload("res://DungeonGeneration/End.tscn")
export(PackedScene) var win = preload("res://DungeonGeneration/Win.tscn")



# Called when the node enters the scene tree for the first time.
func _ready():
	$Game.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_MainMenu_credits():
	var x = credits.instance()
	add_child(x)
	yield(get_tree().create_timer(3.5), "timeout")
	x.queue_free()


func _on_MainMenu_start_game():
	$Game.show()
	$MainMenu.hide()
	$Game.countdown()


func _on_Game_game_over():
	var x = end.instance()
	add_child(x)
	restartgame()
	yield(get_tree().create_timer(3.5), "timeout")
	x.queue_free()
	$MainMenu.show()
	




func _on_Game_game_won():
	var x = win.instance()
	add_child(x)
	restartgame()
	yield(get_tree().create_timer(3.5), "timeout")
	x.queue_free()
	$MainMenu.show()
	


func restartgame():
	$Game.hide()
	$Game.reset()
	
