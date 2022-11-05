extends KinematicBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal current_mana

export var speed = 400
export var acceleration = 100
export var decay = 50.0

var input
var facing_direction = Vector2(1,0)
var velocity = Vector2.ZERO

export(PackedScene) var ProjectileScene
export var projectile_speed = 1000

export var maxmana = 200
var mana
export var manadecay_buffer_max = 20
var manadecay_buffer

var sword_coliding_with_enemies = []
var AOE_colisions = []


# Called when the node enters the scene tree for the first time.
func _ready():
	mana = 0
	manadecay_buffer = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	mana_decay(delta)
	
	emit_signal("current_mana", mana)
	
	movement_controller(delta)

func spawn_projectile(type):
		var projectile = ProjectileScene.instance()
		projectile.position = position
		projectile.velocity = 1000
		projectile.direction = facing_direction.angle()
		projectile.type = 0
		get_parent().add_child(projectile)
		
func sword_attack(type):
	get_node("AnimationPlayer").play("sword_swing")
	for i in sword_coliding_with_enemies:
		if i.has_method("hit_by_sword"):
			i.hit_by_sword(5, facing_direction, 200, type)

func cast_nullification():
	if mana >= maxmana:
		emit_signal("nullification")
	
func cast_aoe():
	for i in AOE_colisions:
		if i.has_method("hit_by_sword"):
			i.hit_by_sword(5, facing_direction, 100, "neutral")


func cast_mana_stop():
	manadecay_buffer = manadecay_buffer_max

func _on_RuneTablet_rune_casted(rune_number):
	if rune_number == 2:
		sword_attack("earth")
	if rune_number == 32:
		sword_attack("fire")
	if rune_number == 8:
		sword_attack("water")
	if rune_number == 128:
		sword_attack("air")
	if rune_number == 186:
		cast_aoe()
	if rune_number == 495:
		cast_nullification()
	if rune_number == 16:
		cast_mana_stop()
		


func mana_decay(delta):
	manadecay_buffer -= delta
	if manadecay_buffer < 0:
		mana -= delta
	if mana < 0:
		mana = 0
		
func movement_controller(_delta):
	input = Vector2.ZERO
	if Input.is_action_pressed("movement_up"):
		input.y -= 1
	if Input.is_action_pressed("movement_down"):
		input.y += 1
	if Input.is_action_pressed("movement_left"):
		input.x -= 1
	if Input.is_action_pressed("movement_right"):
		input.x += 1

	if input != Vector2.ZERO:
		facing_direction = input.normalized()
	
	$Center_of_mass.rotation = atan2(facing_direction.y, facing_direction.x)

	
	velocity += input.normalized() * acceleration
	velocity = velocity.limit_length(speed)
	if velocity.length() > 10:
		velocity -= velocity.normalized() * decay
	else:
		velocity = Vector2.ZERO
	move_and_slide(velocity)
	
func on_door_move(x, y):
	position = position + Vector2(x,y)
	


func _on_SwordHitBox_body_entered(body):
	sword_coliding_with_enemies.append(body)


func _on_SwordHitBox_body_exited(body):
	sword_coliding_with_enemies.erase(body)


func _on_AOE_hitbox_body_entered(body):
	AOE_colisions.append(body)


func _on_AOE_hitbox_body_exited(body):
	AOE_colisions.erase(body)
