extends Camera2D
@onready var player = $"../player/playerchar"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
#skibidia


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player != null:
		position = lerp(position,player.position,position_smoothing_speed * delta)
