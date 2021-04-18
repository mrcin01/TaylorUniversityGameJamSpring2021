extends KinematicBody2D

signal dead


export var moving : bool = true
export var speed = 200
export var movementRange : int

var direction = "left"
var movement_cycle = movementRange
var vel : Vector2 = Vector2()
var alive = true
var deathCount = 20

onready var sprite : AnimatedSprite = get_node("AnimatedSprite")
onready var hitbox : Area2D = get_node("Hitbox")
onready var hitboxShape : CollisionShape2D = get_node("Hitbox/HitboxShape")
onready var hurtbox : Area2D = get_node("Hurtbox")
onready var hurtboxShape : CollisionShape2D = get_node("Hurtbox/HurtboxShape")


func _physics_process(delta):
	if moving and alive:
		vel.x = 0
		if direction == "left":
			vel.x -= speed
		elif direction == "right":
			vel.x += speed
		vel.x = min(max(-1*speed, vel.x), speed)
		# applying the velocity
		vel = move_and_slide(vel, Vector2.UP)


func _process(delta):
	if moving:
		if movement_cycle > 0:
			movement_cycle -= 1
		if movement_cycle == 0:
			movement_cycle = movementRange
			if direction == "left":
				direction = "right"
			elif direction == "right":
				direction = "left"
	if alive == false:
		if deathCount > 0:
			deathCount -= 1
		else:
			get_tree().queue_delete(self)
	
	animations()


func animations():
	if moving:
		if direction == "left":
			sprite.flip_h = false
		elif direction == "right":
			sprite.flip_h = true
		sprite.play("moving")
	elif alive == false:
		sprite.play("death")
	else:
		sprite.play("idle")



func _on_Hurtbox_area_entered(area):
	moving = false
	alive = false
	hurtboxShape.disabled = true
	hitboxShape.disabled = true
	emit_signal("dead")
