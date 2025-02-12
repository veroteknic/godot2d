extends CharacterBody2D

# Node references
@onready var swordanim = $swordanim
@onready var sword_sprite = $swordie
@onready var timer = $killtimer
@onready var sprint = $sprint
@onready var audio_player = $jumpstart
@onready var collision_shape_2d = $CollisionShape2D
@onready var sprite_2d = $player
@onready var kill_player = $AudioStreamPlayer2
@onready var game_manager = $"../GameManager"
@onready var kill = $kill
@onready var footsteps = $footsteps
@onready var footstep_timer = $footsteptimer
@onready var land_sound = $jumpland
@onready var sword_miss_sound = $swordmiss
@onready var sword_hit_sound = $swordhit
@onready var camera = $"../Camera2D"
@onready var dash_activate: AudioStreamPlayer2D = $DashActivate
@onready var firstsheath: AudioStreamPlayer2D = $FirstTimeSheath

# Movement sh#t
var SPEED = 600
var JUMP_VELOCITY = -905
var DASH_SPEED = 1250
var DASH_DURATION = 0.1
var DASH_COOLDOWN = 0.8  
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Dash trail variables
var dash_trail_timer = 0.015  
var last_trail_time = 0.0

# State tracking
var was_in_air = false
var double_jump_used = false
var facing_right = true
var is_dashing = false
var dash_time_left = 0.0
var dash_cooldown_timer = 0.0

func _ready():
	Engine.time_scale = 1
	firstsheath.play()

func _physics_process(delta):
	_handle_gravity(delta)
	_handle_dash(delta)
	_handle_movement()
	_handle_jump()
	_handle_landing()
	_handle_sword_swing()
	move_and_slide()

# ---------------- Dash boi ----------------

func _handle_dash(delta):
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	if is_dashing:
		dash_time_left -= delta
		last_trail_time -= delta  

		if last_trail_time <= 0:
			_spawn_dash_trail()
			last_trail_time = dash_trail_timer  

		_set_animation("running")  

		if dash_time_left <= 0:
			is_dashing = false  
			_set_animation("idle")  
		return  

	if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0:
		_start_dash()

func _start_dash():
	dash_activate.play()
	is_dashing = true
	dash_time_left = DASH_DURATION
	dash_cooldown_timer = DASH_COOLDOWN
	var dash_direction = 1 if facing_right else -1
	velocity.x = dash_direction * DASH_SPEED  

	print("Dashing!")

# ---------------- Dash trel Effect ----------------

func _spawn_dash_trail():
	var trail = AnimatedSprite2D.new()
	trail.sprite_frames = sprite_2d.sprite_frames  
	trail.animation = sprite_2d.animation  
	trail.frame = sprite_2d.frame  
	trail.flip_h = sprite_2d.flip_h  
	trail.position = global_position  
	trail.scale = sprite_2d.scale  
	trail.modulate = Color(1, 1, 1, 0.6)  

	# 🔥 Ensure clone is behind the player
	trail.z_index = sprite_2d.z_index - .5

	get_parent().add_child(trail)  

	var tween = create_tween()
	tween.tween_property(trail, "modulate:a", 0.0, 0.5)  
	tween.tween_callback(trail.queue_free)  

# ---------------- Movement & Physics ----------------

func _handle_gravity(delta):
	if not is_on_floor() and not is_dashing:
		velocity.y += gravity * delta

func _handle_movement():
	if is_dashing:
		return  

	var direction = Input.get_axis("left", "right")

	if direction != 0:
		velocity.x = lerp(velocity.x, direction * SPEED, 0.15)  
		_handle_running_sound()
		_set_animation("running")
	else:
		velocity.x = move_toward(velocity.x, 0, 50)  
		_stop_running_sound()
		_set_animation("idle")

	if direction < 0 and facing_right:
		_flip_player(false)
	elif direction > 0 and not facing_right:
		_flip_player(true)

func _flip_player(is_right: bool):
	facing_right = is_right
	sprite_2d.flip_h = not is_right  
	if sword_sprite is Sprite2D or sword_sprite is AnimatedSprite2D:
		sword_sprite.flip_h = not is_right  

	var idle_anim = "idle_right" if facing_right else "idle_left"
	swordanim.play(idle_anim)

# ---------------- fotstep ----------------

func _handle_running_sound():
	if is_on_floor() and velocity.x != 0 and not is_dashing:
		if footstep_timer.is_stopped():
			footstep_timer.start()
		if not footsteps.is_playing():
			footsteps.play()
	else:
		_stop_running_sound()

func _stop_running_sound():
	footstep_timer.stop()
	footsteps.stop()
func _on_footsteptimer_timeout():
	if is_on_floor() and velocity.x != 0 and not is_dashing:
		footsteps.play()

# ---------------- Jump & Landing ----------------

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
		if was_in_air:
			land_sound.play()
			print("Landed!")
		was_in_air = false
		double_jump_used = false  
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
		var swing_anim = "slash" if facing_right else "slash_left"
		if swordanim.current_animation != swing_anim or not swordanim.is_playing():
			swordanim.play(swing_anim)  
			sword_miss_sound.play()
			if $Area2D.get_overlapping_bodies():
				sword_hit_sound.play()  
				_apply_hitstop()

# ---------------- Hit Effects  ----------------

func _apply_hitstop():
	_character_flash()  

	Engine.time_scale = 0.02  
	await get_tree().create_timer(0.02).timeout  
	Engine.time_scale = 1.0  

func _character_flash():
	sprite_2d.self_modulate = Color(2, 2, 2, 1) 
	await get_tree().create_timer(0.05).timeout  
	sprite_2d.self_modulate = Color(1, 1, 1, 1)  

# ---------------- signal sh#t ----------------

func _on_area_2d_area_entered(area):
	area.queue_free()
	sword_hit_sound.play()
	_apply_hitstop()

func _on_key_body_entered(body: Node2D) -> void:
	$SecretRoomAudio.play()
	$"../../key".queue_free()
	$"../../StaticBody2D".queue_free()
	print("debug open door epically")
