extends StaticBody2D
@onready var ray_cast_right = $RayCast2D
@onready var ray_cast_left = $RayCast2D2
var direction = 1
const SPEED = 200

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if ray_cast_right.is_colliding():
		direction = -1
	if ray_cast_left.is_colliding():
		direction = 1

	position.x += direction * SPEED * delta
