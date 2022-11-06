extends Area2D


# Declare member variables here. Examples:
var earth = preload("res://Assets/UI/Tutorial/UI_Tutorial_EarthSlash.png")
var water = preload("res://Assets/UI/Tutorial/UI_Tutorial_WaterSlash.png")
var air = preload("res://Assets/UI/Tutorial/UI_Tutorial_AirSlash.png")
var fire = preload("res://Assets/UI/Tutorial/UI_Tutorial_FireSlash.png")
var heal = preload("res://Assets/UI/Tutorial/UI_Tutorial_HealingSpell.png")
var nulli = preload("res://Assets/UI/Tutorial/UI_Tutorial_Nullification.png")


var player

var possible_tutorials = [water, air, fire, heal]


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("bounce")
	$Hint.hide()
	$Node/Content.texture = possible_tutorials[randi() % possible_tutorials.size()]
	$Node/Content.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Pedastal_body_entered(body):
	if body.has_method("dummy_method_only_player_has"):
		$Hint.show()
		
		if player == null:
			player = body



func _on_Pedastal_body_exited(body):
	if body.has_method("dummy_method_only_player_has"):
		$Hint.hide()


func _unhandled_input(event):
	if player == null:
		return

	if Input.is_action_just_pressed("interact") and overlaps_body(player):
		$Node/Content.show()
	if Input.is_action_just_released("interact"):
		$Node/Content.hide()


func left_spawn():
	$Node/Content.texture = earth
	
func right_spawn():
	$Node/Content.texture = nulli
	
func pick(i):
	$Node/Content.texture = possible_tutorials[i % possible_tutorials.size()]

