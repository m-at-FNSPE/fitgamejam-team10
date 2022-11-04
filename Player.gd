extends KinematicBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var speed = 400
export var acceleration = 100
export var decay = 50.0

var velocity = Vector2.ZERO

export(PackedScene) var ProjectileScene
export var projectile_speed = 1000

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var input = Vector2.ZERO
	if Input.is_action_pressed("movement_up"):
		input.y -= 1
	if Input.is_action_pressed("movement_down"):
		input.y += 1
	if Input.is_action_pressed("movement_left"):
		input.x -= 1
	if Input.is_action_pressed("movement_right"):
		input.x += 1
	if Input.is_action_just_pressed("debug_action"):
		var projectile = ProjectileScene.instance()
		projectile.position = Vector2.ZERO
		projectile.velocity = 30
		projectile.direction = input.angle()
		add_child(projectile)
	
	velocity += input.normalized() * acceleration
	velocity = velocity.limit_length(speed)
	if velocity.length() > 10:
		velocity -= velocity.normalized() * decay
	else:
		velocity = Vector2.ZERO
	
	position += velocity * delta
