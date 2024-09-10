extends StaticBody2D
@onready var ray_cast_up = $RayCast2D
@onready var ray_cast_down = $RayCast2D2
var direction = 1
const SPEED = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if ray_cast_up.is_colliding():
		direction = 1
	if ray_cast_down.is_colliding():
		direction = -1

	position.y += direction * SPEED * delta
