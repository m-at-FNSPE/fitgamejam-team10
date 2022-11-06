extends KinematicBody2D


export var maxspeed = 90

var default_scale: Vector2
var player: KinematicBody2D
var direction

export var life = 20
var velocity = 0
var acceleration = 10
var decay = 12

signal die


export(PackedScene) var death = preload("res://Enemies/Death.tscn")

var normal_acceleration = acceleration

# Called when the node enters the scene tree for the first time.
func _ready():
	find_player()
	default_scale = Vector2(scale.x, scale.y)


func find_player():
	player = get_tree().current_scene.find_node("Player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player:
		chase(delta)
	
	turn_to_direction()




func chase(delta):
	direction = player.position - position
	direction = direction.normalized()
	
	velocity += acceleration
	if abs(velocity) > maxspeed:
		velocity = sign(velocity) * abs(abs(velocity) - decay)
#	velocity = clamp(velocity, -INF, maxspeed)
	

	move_and_slide(direction * velocity)

func turn_to_direction():
	if (scale.x < 0 and not direction.x > 0) or direction.x < 0:
		scale.x =  scale.y
	else:
		scale.x = -1 * scale.y
		
func hit_by_sword(damage:int , dir:Vector2, knockback ,_type):
	life -= damage
	velocity = -knockback
	direction = dir
	if life < 0:
		die()
		
func dealt_damage_to_player():
	direction = player.position - position
	velocity = -500
		
func die():
	emit_signal("die", self)
	var x = death.instance()
	get_tree().root.get_child(0).call_deferred("add_child", x)
	x.position = position
	queue_free()
	
