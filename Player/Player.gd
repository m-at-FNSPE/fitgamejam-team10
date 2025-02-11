extends KinematicBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal current_mana
signal current_health 

signal nullification

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

var health = 200
var max_health = 200

var sword_coliding_with_enemies = []
var AOE_colisions = []


# Called when the node enters the scene tree for the first time.
func _ready():
	mana = 0
	manadecay_buffer = 0
	$AnimatedSprite.play("player");

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	mana_decay(delta)
	
	emit_signal("current_mana", mana)
	emit_signal("current_health", health)
	
	movement_controller(delta)
	
	if velocity.length() != 0:
		if $Timer.time_left <= 0:
			$AudioStreamPlayer.pitch_scale = rand_range(0.8, 1.2)
			$AudioStreamPlayer.play()
			$Timer.start(0.2)
	else:
		$AudioStreamPlayer.seek(0)
		$AudioStreamPlayer.playing = false
		


func spawn_projectile(type):
		var projectile = ProjectileScene.instance()
		projectile.position = position
		projectile.velocity = 1000
		projectile.direction = facing_direction.angle()
		projectile.type = 0
		get_parent().add_child(projectile)
		
func sword_attack(type):
	if type == "air":
		$Center_of_mass/Sprite.modulate = Color(0, 1.74, 7.52)
	elif type == "earth":
		$Center_of_mass/Sprite.modulate = Color(0.6, 0.33, 0.07)
	elif type == "water":
		$Center_of_mass/Sprite.modulate = Color(0, 0.78, 21)
	else:
		$Center_of_mass/Sprite.modulate = Color(1, 1, 1)
	$Spell.play()
	get_node("AnimationPlayer").play("cast")
	for i in sword_coliding_with_enemies:
		if i.has_method("hit_by_sword"):
			i.hit_by_sword(5, facing_direction, 200, type)
			mana += 5

func cast_nullification():
	if mana >= maxmana - 10:
		$Nullify.play()
		emit_signal("nullification")
	
func cast_aoe():
	$AOE.play()
	get_node("AnimationPlayer").play("AOE")
	for i in AOE_colisions:
		if i.has_method("hit_by_sword"):
			i.hit_by_sword(7, facing_direction, 100, "neutral")


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
	if rune_number == 338:
		cast_heal()

func cast_heal():
	health = health + mana
	mana = 0
	if health > 200:
		mana = health - 200


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
		$AnimatedSprite.scale.x = -1;
	if Input.is_action_pressed("movement_right"):
		input.x += 1
		$AnimatedSprite.scale.x = 1;
		

	if input != Vector2.ZERO:
		facing_direction = input.normalized()
	
	$Center_of_mass.rotation = atan2(facing_direction.y, facing_direction.x)

	
	velocity += input.normalized() * acceleration
	velocity = velocity.limit_length(speed)
	if velocity.length() > 20:
		velocity -= velocity.normalized() * decay
	elif velocity.length() > 10:
		velocity -= velocity.normalized() * decay/2
	else:
		velocity = Vector2.ZERO
	move_and_slide(velocity)
	
func dummy_method_only_player_has():
	pass
	
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


func _on_HitBox_body_entered(body):
	if body.has_method("dealt_damage_to_player"):
		body.dealt_damage_to_player()
		move_and_slide( 900 * (position - body.position).normalized())
		health -= 10
