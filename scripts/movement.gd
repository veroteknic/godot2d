extends CharacterBody2D

const SPEED = 600
const JUMP_VELOCITY = -905
@onready var timer = $Timer
@onready var audio_player = $AudioStreamPlayer
@onready var collision_shape_2d = $CollisionShape2D
@onready var sprite_2d = $AnimatedSprite2D
@onready var kill_player = $AudioStreamPlayer2
@onready var game_manager = $"../GameManager"


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var double_jump_used = false
@export var health: int = 6
func _ready():
	Engine.time_scale = 1

func _physics_process(delta):
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
		sprite_2d.flip_h = true
	elif velocity.x > 0:
		sprite_2d.flip_h = false
	
	if Input.is_action_just_pressed("jump"):
		health -= 1
		print(health)
