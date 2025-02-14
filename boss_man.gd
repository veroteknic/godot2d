extends CharacterBody2D

# Node references
@onready var anim = $AnimatedSprite2D
@onready var fire_particles = $CPUParticles2D
@onready var stomp_timer = $StompTimer
@onready var fire_timer = $FireTimer
@onready var player = get_parent().find_child("player")  # Finds the player in the scene

# Boss properties
@export var health = 10
@export var speed = 50
@export var jump_force = -500
@export var gravity = 900
var is_attacking = false
var direction = 1  # Left (-1) or Right (1)

func _ready():
	fire_particles.emitting = false
	stomp_timer.start()
	fire_timer.start()

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Move only if not attacking
	if not is_attacking and player:
		direction = 1 if player.global_position.x > global_position.x else -1
		velocity.x = direction * speed
		anim.play("run")  # ✅ Use run animation for movement
	else:
		velocity.x = 0
		anim.play("idle")  # ✅ Use idle animation when stopping

	move_and_slide()

func _on_stomp_timer_timeout():
	if not is_attacking:
		_perform_stomp()

func _on_fire_timer_timeout():
	if not is_attacking:
		_perform_fire_attack()

# ----- STOMP ATTACK -----
func _perform_stomp():
	is_attacking = true
	anim.play("run")  # ✅ Use run animation as a fake jump

	# Jump
	velocity.y = jump_force
	await get_tree().create_timer(0.8).timeout  # Simulated airtime

	# Land
	velocity.y = 0
	_shake_screen()
	_damage_nearby_players()
	
	anim.play("idle")  # ✅ Use idle animation for landing
	is_attacking = false

func _shake_screen():
	if player:
		var camera = $Camera2D
		if camera:
			camera.offset = Vector2(randf_range(-5, 5), randf_range(-5, 5))
			await get_tree().create_timer(0.2).timeout
			camera.offset = Vector2.ZERO

func _damage_nearby_players():
	if player and global_position.distance_to(player.global_position) < 100:
		player.take_damage(2)

# ----- FIRE ATTACK -----
func _perform_fire_attack():
	is_attacking = true
	anim.play("idle")  # ✅ Use idle animation to fake a charging pose
	await get_tree().create_timer(0.5).timeout

	fire_particles.emitting = true
	await get_tree().create_timer(1.5).timeout  # Fire duration
	fire_particles.emitting = false

	is_attacking = false

# ----- DAMAGE & DEATH -----
func take_damage(amount):
	health -= amount
	print("Boss HP:", health)

	if health <= 0:
		_die()

func _die():
	anim.play("idle")  # ✅ Use idle animation as a death pose
	await get_tree().create_timer(1.0).timeout
	queue_free()
