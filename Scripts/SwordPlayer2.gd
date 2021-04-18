extends KinematicBody2D


signal level_exit


export var maxSpeed = 400
export var jumpForce = 500
export var gravity = 1250

var speed = maxSpeed
var vel : Vector2 = Vector2()
const maxAttackTimer = 40
var attackTimer = 0
var alive = true
var deathCount = 65
var dashCooldown = 0
var speedTimer = 0
var forceX = 0
var landing : bool
var superDashTimer = 0
var jump_count = 1
var levelLeave = false
var leaveLevelCount = -1
var stopwatchBool = true
var finalTime : String
var enemy_killed_time = 0
var priorBestTime


onready var sprite : AnimatedSprite = get_node("AnimatedSprite")
onready var hitbox : Area2D = get_node("Hitbox")
onready var hitboxShape : CollisionShape2D = get_node("Hitbox/HitboxShape")
onready var hurtbox : Area2D = get_node("Hurtbox")
onready var hurtboxShape : CollisionShape2D = get_node("Hurtbox/HurtboxShape")
onready var stopwatch : Label = get_parent().get_node("CanvasLayer/Stopwatch")
onready var inital_msecs = OS.get_ticks_msec()

func _physics_process(delta):
	vel.x = 0
	if alive and levelLeave == false: 
		# Moving Left
		if Input.is_action_pressed("move_left"):
			vel.x -= speed
		# Moving Right
		if Input.is_action_pressed("move_right"):
			vel.x += speed
		if Input.is_action_pressed("jump") and attackTimer == 0 and jump_count == 1:
			if is_on_floor():
				vel.y -= jumpForce
			else:
				vel.y -= jumpForce * 1.5
			jump_count -= 1
		if (Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")) and Input.is_action_pressed("dash") and dashCooldown == 0 and superDashTimer > 0:
			if Input.is_action_pressed("move_left"):
				forceX = -20000
			if Input.is_action_pressed("move_right"):
				forceX = 20000
			dashCooldown = 20
			speedTimer = 10
			speed = 1600
			sprite.scale.y = 0.5
		elif (Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")) and Input.is_action_pressed("dash") and dashCooldown == 0:
			if Input.is_action_pressed("move_left"):
				forceX = -10000
			if Input.is_action_pressed("move_right"):
				forceX = 10000
			dashCooldown = 20
			speedTimer = 10
			speed = 1200
			sprite.scale.y = 0.65
		vel.x += forceX
	
		vel.x = min(max(-1*speed, vel.x), speed)
		
		# applying the velocity
		vel = move_and_slide(vel, Vector2.UP)

		# gravity
		vel.y += gravity * delta
	


func _process(_delta):
	if stopwatchBool:
		stopwatch.text = formatted_time()
	if alive:
		if Input.is_action_just_pressed("attack") and attackTimer == 0 and is_on_floor() and levelLeave == false:
			sprite.play("attack")
			attackTimer = maxAttackTimer
			hurtboxShape.disabled = true
		
		# Check if player just landed
		if is_on_floor():
			if landing:
				landing = false
				superDashTimer = 6
				jump_count = 1
		else:
			if !landing:
				landing = true
		
		
		if attackTimer == 40:
			 hitboxShape.disabled = false
		elif attackTimer == 5:
			hitboxShape.disabled = true
		elif attackTimer == 0:
			hurtboxShape.disabled = false
		
		if attackTimer > 0:
			attackTimer -= 1
		
		if superDashTimer > 0:
			superDashTimer -= 1
		if dashCooldown > 0:
			dashCooldown -= 1
		if speedTimer > 0:
			speedTimer -= 1
		elif speedTimer == 0:
			speed = maxSpeed
			forceX = 0
			sprite.scale.y = 1
		if leaveLevelCount > 0:
			leaveLevelCount -= 1
		elif leaveLevelCount == 0:
			get_parent().get_node("CanvasLayer/BackToMenuButton").visible = true
			get_parent().get_node("CanvasLayer/ResetButton").visible = true
			get_parent().get_node("CanvasLayer/Win Label").visible = true
			get_parent().get_node("CanvasLayer/YourScore").text = "Your Score: " + finalTime
			get_parent().get_node("CanvasLayer/YourScore").visible = true
			get_parent().get_node("CanvasLayer/BestScore").text = "Best Score: " + priorBestTime
			get_parent().get_node("CanvasLayer/BestScore").visible = true
		
	elif alive == false:
		if deathCount > 0:
			deathCount -= 1
		else:
			get_tree().reload_current_scene()
	
	animations()
	

func animations():
	if is_on_floor() and alive and levelLeave == false:
		# Change Directions
		# Facing Right
		if vel.x > 0:
			sprite.flip_h = false
			hitbox.position.x = 20
			hitboxShape.rotation_degrees = 90
			if attackTimer == 0:
				sprite.play("running")
		# Facing Left
		elif vel.x < 0:
			sprite.flip_h = true
			hitbox.position.x = -20
			hitboxShape.rotation_degrees = -90
			if attackTimer == 0:
				sprite.play("running")
		else:
			if attackTimer == 0:
				sprite.play("idle")
	elif alive == false:
		sprite.play("death")
	elif levelLeave:
		sprite.play("levelLeave")
		sprite.scale.y -= .007
		sprite.scale.x -= .007
	else:
		if vel.x > 0:
			sprite.flip_h = false
		elif vel.x < 0:
			sprite.flip_h = true
		sprite.play("jump")


func _on_Hurtbox_area_entered(area):
	alive = false



func _on_Level_Exit_body_entered(body):
	if body.get_name() == "SwordPlayer":
		emit_signal("level_exit")
		levelLeave = true
		leaveLevelCount = 250
		stopwatchBool = false
		finalTime = stopwatch.text
		var finalTimeVal = formatted_time_to_val(finalTime)
		var prev_best = Load()
		priorBestTime = prev_best
		if prev_best == null:
			Save(finalTime)
		else:
			prev_best = formatted_time_to_val(prev_best)
			if finalTimeVal < prev_best:
				Save(finalTime)



func formatted_time():
	var digit_format = "%02d"
	var formatted : String
	var msecs = OS.get_ticks_msec() - inital_msecs - (enemy_killed_time * 1000)
	var milliseconds = digit_format % [msecs % 1000]
	var seconds = digit_format % [(msecs / 1000) % 60]
	var minutes = digit_format % [msecs / 60000]
	formatted = minutes + " : " + seconds + " : " + milliseconds
	return formatted

func formatted_time_to_val(timeString):
	var minutes = int(timeString.substr(0,2))
	var seconds = int(timeString.substr(5,2))
	var milliseconds = int(timeString.substr(10,3))
	var total = (minutes * 60000) + (seconds * 1000) + milliseconds
	return total


func Save(content):
	var file = File.new()
	file.open("res://level2.dat", File.WRITE)
	file.store_string(content)
	file.close()

func Load():
	var file = File.new()
	file.open("res://level2.dat", File.READ)
	var content = file.get_as_text()
	file.close()
	return content


func _on_Slime1_dead():
	enemy_killed_time += 2

