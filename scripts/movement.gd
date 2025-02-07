extends CharacterBody2D

# Preload and cache node references for better performance
@onready var swordanim = $swordanim  # AnimationPlayer for sword
@onready var sword_sprite = $swordie  # The actual sword sprite
@onready var timer = $killtimer
@onready var sprint = $sprint
@onready var audio_player = $jumpstart
@onready var collision_shape_2d = $CollisionShape2D
@onready var sprite_2d = $player  # The main player sprite
@onready var kill_player = $AudioStreamPlayer2
@onready var game_manager = $"../GameManager"
@onready var kill = $kill
@onready var footsteps = $footsteps
@onready var footstep_timer = $footsteptimer
@onready var land_sound = $jumpland  # Landing sound
@onready var sword_miss_sound = $swordmiss
@onready var sword_hit_sound = $swordhit

# Movement and game variables
var SPEED = 600
var JUMP_VELOCITY = -905
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var was_in_air = false
var double_jump_used = false
@export var health: int = 6
var enemyhealth = 3
var facing_right = true  # Track the player's direction

func _ready():
	Engine.time_scale = 1

func _physics_process(delta):
	_handle_gravity(delta)
	_handle_movement()
	_handle_jump()
	_handle_landing()
	_handle_sword_swing()
	move_and_slide()

# ---------------- Movement & Physics ----------------

func _handle_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

func _handle_movement():
	var direction = Input.get_axis("left", "right")

	# Smooth acceleration using lerp
	if direction != 0:
		velocity.x = lerp(velocity.x, direction * SPEED, 0.15)
		_handle_running_sound()
		_set_animation("running")
	else:
		velocity.x = move_toward(velocity.x, 0, 50)
		_stop_running_sound()
		_set_animation("idle")

	# Flip player and sword immediately
	if direction < 0 and facing_right:
		_flip_player(false)
	elif direction > 0 and not facing_right:
		_flip_player(true)

func _flip_player(is_right: bool):
	facing_right = is_right
	sprite_2d.flip_h = not is_right  # Flip player sprite
	
	# Ensure we're flipping the actual sword sprite, NOT the AnimationPlayer
	if sword_sprite is Sprite2D or sword_sprite is AnimatedSprite2D:
		sword_sprite.flip_h = not is_right  # Flip sword sprite correctly
	
	# 🔹 FIX: Immediately update sword animation so it matches the direction
	var idle_anim = "idle_right" if facing_right else "idle_left"
	swordanim.play(idle_anim)

func _handle_running_sound():
	if is_on_floor():
		if footstep_timer.is_stopped():
			footstep_timer.start()
		if not footsteps.is_playing():
			footsteps.play()

func _stop_running_sound():
	footsteps.stop()
	footstep_timer.stop()

func _handle_jump():
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			audio_player.play()
		elif not double_jump_used:
			velocity.y = JUMP_VELOCITY * 1.2
			audio_player.play()
			double_jump_used = true

func _handle_landing():
	if is_on_floor():
		if was_in_air:  # Play landing sound only when transitioning from air to floor
			land_sound.play()
			print("Landed!")
		was_in_air = false
		double_jump_used = false  # Reset double jump
	else:
		was_in_air = true
		_set_animation("falling")

# ---------------- Animations & Combat ----------------

func _set_animation(state: String):
	if sprite_2d.animation != state:
		sprite_2d.animation = state

func _handle_sword_swing():
	if Input.is_action_just_pressed("swing"):
		print("Swing!")

		# Choose the correct swing animation based on facing direction
		var swing_anim = "slash" if facing_right else "slash_left"

		# 🔹 Only play the sound if the sword actually starts swinging
		if swordanim.current_animation != swing_anim or not swordanim.is_playing():
			swordanim.play(swing_anim)  # Restart the animation
			sword_miss_sound.play()

			# Check if an enemy is hit
			if $Area2D.get_overlapping_bodies():
				sword_hit_sound.play()  # Play hit sound if enemy is hit

# ---------------- Signals & Collision Handling ----------------

func _on_area_2d_area_entered(area):
	area.queue_free()
	sword_hit_sound.play()

func _on_footsteptimer_timeout():
	footsteps.play()

func _on_key_body_entered(body: CharacterBody2D):
	# Remove key and static body on interaction
	$"../../key".queue_free()
	$"../../StaticBody2D".queue_free()
