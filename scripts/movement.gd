extends CharacterBody2D

var SPEED = 600
var JUMP_VELOCITY = -905
@onready var timer = $killtimer
@onready var sprint = $sprint
@onready var audio_player = $AudioStreamPlayer
@onready var collision_shape_2d = $CollisionShape2D
@onready var sprite_2d = $player
@onready var kill_player = $AudioStreamPlayer2
@onready var game_manager = $"../GameManager"
@onready var cpu_particles_2d = $CPUParticles2D
@onready var sword = $player/sword
@onready var kill = $kill


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var double_jump_used = false
@export var health: int = 6
func _ready():
	Engine.time_scale = 1
func _physics_process(delta):
	if is_on_floor():
		print("On floor, emitting particles")
		cpu_particles_2d.emitting = true
	else:
		print("Not on floor, stopping particles")
		cpu_particles_2d.emitting = false
	if (velocity.x > 1 or velocity.x < -1):
		sprite_2d.animation = "running"
	else:
		sprite_2d.animation = "idle"
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		sprite_2d.animation = "falling"
	
	# Handle Jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			audio_player.play()
		elif not is_on_floor() and not double_jump_used:
			velocity.y = JUMP_VELOCITY * 1.2
			audio_player.play()
			double_jump_used = true
	if is_on_floor():
		double_jump_used = false
	
	var direction = Input.get_axis("left", "right")
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, 50)
	
	move_and_slide()

	if velocity.x < 0:
		var tween = create_tween()
		sprite_2d.flip_h = true
		tween.tween_property(sword, "rotation", rotation + deg_to_rad(270), 0.1)
	elif velocity.x > 0:
		var tween = create_tween()
		sprite_2d.flip_h = false
		sword.flip_h = false
		tween.tween_property(sword, "rotation", rotation + deg_to_rad(-270), 0.1)

# Combined swing input handling
	if Input.is_action_just_pressed("swing"):
		if velocity.x > 0:
			var tween = create_tween()
			tween.tween_property(sword, "rotation", rotation + deg_to_rad(0), 0.1)  # Reset rotation
			tween.tween_property(sword, "rotation", rotation + deg_to_rad(100), 0.1) # Swing effect
	elif velocity.x < 0:
		var tween = create_tween()
		tween.tween_property(sword, "rotation", rotation + deg_to_rad(0), 0.1)
		tween.tween_property(sword, "rotation", rotation - deg_to_rad(-100), 0.1)

func _on_sprint_timeout():
	SPEED - 600
	print("sprint over")




func _on_area_2d_body_entered(body):
	pass
