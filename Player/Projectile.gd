extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var velocity = 100
export var direction = 0
var lifetime = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += Vector2.RIGHT.rotated(direction) * velocity * delta
	lifetime += delta
	
	if lifetime > 5:
		queue_free()
	

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
