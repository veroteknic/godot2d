extends CharacterBody2D

@onready var swordanim = $swordanim
@onready var timer = $killtimer
@onready var sprint = $sprint
@onready var audio_player = $jumpstart
@onready var collision_shape_2d = $CollisionShape2D
@onready var sprite_2d = $player
@onready var kill_player = $AudioStreamPlayer2
@onready var game_manager = $"../GameManager"
@onready var kill = $kill
@onready var swordie = $swordie
@onready var footsteps = $footsteps
@onready var footstep_timer = $footsteptimer
@onready var land_sound = $jumpland  # Correct name for the landing sound

var SPEED = 600
var JUMP_VELOCITY = -905
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var was_in_air = false
var double_jump_used = false
@export var health: int = 6
var enemyhealth = 3

func _ready():
	Engine.time_scale = 1

func _physics_process(delta):
	# Handle horizontal movement and footstep logic
	if velocity.x != 0 and is_on_floor():
		if footstep_timer.is_stopped():
			footstep_timer.start()
		if not footsteps.is_playing():
			footsteps.play()
		sprite_2d.animation = "running"
	else:
		footsteps.stop()
		footstep_timer.stop()
		sprite_2d.animation = "idle"

	# Add gravity when not on the floor
	if not is_on_floor():
		velocity.y += gravity * delta
		sprite_2d.animation = "falling"
	
	# Handle jumping and double jump
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			audio_player.play()  # Play jump start sound
		elif not is_on_floor() and not double_jump_used:
			velocity.y = JUMP_VELOCITY * 1.2
			audio_player.play()  # Play double jump sound
			double_jump_used = true

	# Handle landing sound
	if is_on_floor():
		if was_in_air:  # Play landing sound only once when transitioning from air to floor
			land_sound.play()
			print("landed")
		was_in_air = false
		double_jump_used = false  # Reset double jump
	else:
		was_in_air = true

	# Handle directional input
	var direction = Input.get_axis("left", "right")
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, 50)

	move_and_slide()

	# Flip sprite and handle animation direction
	if velocity.x < 0:
		sprite_2d.flip_h = true
		swordanim.play("idle_left")
		swordanim.play("slash_left")
		swordanim.stop()
	elif velocity.x > 0:
		sprite_2d.flip_h = false
		swordanim.play("idle_right")
		swordanim.play("slash")
		swordanim.stop()

	# Handle sword swing
	if Input.is_action_just_pressed("swing"):
		print("swinggg")
		swordanim.play()
		$swordmiss.play()
		if not $Area2D.get_overlapping_bodies():
			$swordmiss.play()  # Play miss sound when no collision occurs

func _on_area_2d_area_entered(area):
	area.queue_free()
	$swordhit.play()

func _on_footsteptimer_timeout() -> void:
	footsteps.play()

func _on_key_body_entered(body: CharacterBody2D) -> void:
	# Remove key and static body on interaction
	$"../../key".queue_free()
	$"../../StaticBody2D".queue_free()
