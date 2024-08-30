extends Camera2D
@export var player: Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player != null:
		position = lerp(position,player.position,position_smoothing_speed * delta)
