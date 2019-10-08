extends KinematicBody2D
#Movement
const GRAVITY = 20
const MAX_GRAVITY = 500
const ACCELERATION = 25
const MAX_SPEED = 250
const MAX_UP_SPEED = -MAX_GRAVITY
const JUMP_HEIGHT = -364
const WALK_ACELERATION = ACCELERATION/2
const MAX_WALK_SPEED = MAX_SPEED/2
var motion = Vector2()
var friction = false
#Checkpoint vars
var current_cp = 0 
var cp_position = Vector2(0,0)
#State vars
var is_on_light = false
var is_grabbing = false
var is_facing_right = true
var can_pick = false
var has_torch = false
var picked_torch = false
var has_rock = false
var picked_rock = false
var is_running = false
var dead = false
var respawned_torch = true
var is_counting_darktime = false
#Camera
var camera = null
#Monster
var monster_moving = false
var monster_respawn = false
#sound
var footstep_playing = false
var heart_playing = false
#game status
var game_started = true
#blood
var BLOOD_HIT = preload("res://scenes/effects/Blood_hit.tscn")

func _ready():
	var camera = Camera2D.new()
	add_child(camera)
	camera.current = true
	camera.zoom = Vector2(0.4,0.4)

func _physics_process(delta):
	
	if game_started:		
		if dead == false:
			hit()
			player_movement()		
			

func player_movement():
	friction = false
	
	if is_grabbing_ledge():
		is_grabbing = true
		if Input.is_action_just_pressed("ui_down"):
			motion.y = 200
		else:
			motion = Vector2(0,0)
		jump()
	else:
		is_grabbing = false
	
	if is_grabbing == false:
		motion.y = min(motion.y+GRAVITY, MAX_GRAVITY)
	
	if motion == Vector2(0,0):
		if is_grabbing:
			$AnimatedSprite.play("LedgeGrab")
		else:
			$AnimatedSprite.play("Idle")
		friction = true	
	run()
	walk()
	#Check on floor
	if player_on_floor():
		if friction:
			motion.x = lerp(motion.x, 0, 0.5)
		motion.y = 0
		jump()
		
	else:
		if is_grabbing == false:
			jump_break()			
			if motion.y < 0:
				$AnimatedSprite.play("Jump")
			else:
				$AnimatedSprite.play("Landing")
		else:
			pass
		if friction:
			motion.x = lerp(motion.x, 0, 0.2)
	
	
	motion = move_and_slide(motion, Vector2(0,-1))

func run():
	if Input.is_action_pressed("ui_right") and ((Input.is_action_pressed("ui_C") or Input.is_action_pressed("ui_Shift"))):		
		if is_grabbing and is_facing_right:
			$AnimatedSprite.play("LedgeGrab")
		else:
			if not $LedgeCastNot.is_colliding():
				is_running = true
				motion.x = min(motion.x+ACCELERATION, MAX_SPEED)			
				$AnimatedSprite.play("Run")
			
			$AnimatedSprite.flip_h = false
			flip_collision($TorchCollision, "right")
			$LedgeCastNot.rotation *= -1 if is_facing_right == false else 1
			$TorchCollision.rotation *= -1 if is_facing_right == false else 1
			flip_collision($TorchPos, "right")
			#flip_collision($CollisionPolygon2D, "right")			
			flip_collision($LedgeCast, "right")
			flip_collision($LedgeCastNot, "right", true)
		is_facing_right = true
		
	elif Input.is_action_pressed("ui_left") and ((Input.is_action_pressed("ui_C") or Input.is_action_pressed("ui_Shift"))):		
		if is_grabbing and not is_facing_right:
			$AnimatedSprite.play("LedgeGrab")
		else:
			if not $LedgeCastNot.is_colliding():
				is_running = true
				motion.x = max(motion.x-ACCELERATION, -MAX_SPEED)				
				$AnimatedSprite.play("Run")
				
			$AnimatedSprite.flip_h = true
			flip_collision($TorchCollision, "left")
			$TorchCollision.rotation *= -1 if is_facing_right else 1
			$LedgeCastNot.rotation *= -1 if is_facing_right else 1
			flip_collision($TorchPos, "left")
			#flip_collision($CollisionPolygon2D, "left")			
			flip_collision($LedgeCast, "left")
			flip_collision($LedgeCastNot, "left", true)
		is_facing_right = false
	else:
		if is_grabbing:
			$AnimatedSprite.play("LedgeGrab")
		else:
			is_running = false
			if motion.x == 0:
				$AnimatedSprite.play("Idle")
				friction = true	

func walk():
	if not is_running:
		if Input.is_action_pressed("ui_right"):
			if is_grabbing and is_facing_right:
				$AnimatedSprite.play("LedgeGrab")
			else:
				if not $LedgeCastNot.is_colliding():
					motion.x = min(motion.x+WALK_ACELERATION, MAX_WALK_SPEED)
					$AnimatedSprite.play("Walk")
				
				$AnimatedSprite.flip_h = false
				flip_collision($TorchCollision, "right")
				$LedgeCastNot.rotation *= -1 if is_facing_right == false else 1
				$TorchCollision.rotation *= -1 if is_facing_right == false else 1
				flip_collision($TorchPos, "right")
				#flip_collision($CollisionPolygon2D, "right")
				flip_collision($LedgeCast, "right")
				flip_collision($LedgeCastNot, "right", true)
			is_facing_right = true
			
		elif Input.is_action_pressed("ui_left"):
			if is_grabbing and not is_facing_right:
				$AnimatedSprite.play("LedgeGrab")
			else:
				if not $LedgeCastNot.is_colliding():
					motion.x = max(motion.x-WALK_ACELERATION, -MAX_WALK_SPEED)
					$AnimatedSprite.play("Walk")
				
				$AnimatedSprite.flip_h = true
				flip_collision($TorchCollision, "left")
				$LedgeCastNot.rotation *= -1 if is_facing_right else 1
				$TorchCollision.rotation *= -1 if is_facing_right else 1
				flip_collision($TorchPos, "left")
				#flip_collision($CollisionPolygon2D, "left")			
				flip_collision($LedgeCast, "left")
				flip_collision($LedgeCastNot, "left", true)
			is_facing_right = false
		else:
			if is_grabbing:
				$AnimatedSprite.play("LedgeGrab")
			else:
				$AnimatedSprite.play("Idle")
				friction = true

func player_on_floor():
	return $CheckFloor.is_colliding() or $CheckFloor2.is_colliding()

func jump():
	if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_select"):
		motion.y = 0
		motion.y += JUMP_HEIGHT - abs(motion.x)/2

func jump_break():
	if Input.is_action_just_released("ui_up") and motion.y < 0:
		motion.y = lerp(motion.y, 0, 0.5)

func flip_collision(object, side, flip_cast=false):
	if object.position.x < 0 and side == "right":
		object.position.x *= -1
		if flip_cast:
			object.cast_to.x *= -1
	if object.position.x > 0 and side == "left":
		object.position.x *= -1
		if flip_cast:
			object.cast_to.x *= -1
	
func is_grabbing_ledge():
	if $LedgeCast.is_colliding():
		if not $LedgeCastNot.is_colliding():
			return true
	is_grabbing = false
	return false

func hit():
	if Input.is_action_just_pressed("ui_cancel"):
		var blood = BLOOD_HIT.instance()
		add_child(blood)