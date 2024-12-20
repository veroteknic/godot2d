extends Node2D

@onready var audio_stream_player = $AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	audio_stream_player.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
