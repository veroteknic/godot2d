extends Node2D
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@export var health: int = 3  # Example health value for the enemy

const SPEED = 100

var direction = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	

	add_to_group("enemies")
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite_2d.animation = "chase"
		animated_sprite_2d.flip_h = true
	if ray_cast_left.is_colliding():
		animated_sprite_2d.animation = "chase"
		direction = 1
		animated_sprite_2d.flip_h = false

	position.x += direction * SPEED * delta




# Call this when the enemy is hit by the sword
func kill():
	queue_free()  # Remove the enemy from the scene
