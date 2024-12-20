extends RigidBody2D
@onready var player = $"../player"



# Called when the node enters the scene tree for the first time.
func _ready():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player != null:
		position = player.position
