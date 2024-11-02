extends Area2D
@onready var animated_sprite_2d = $"../AnimatedSprite2D"
@onready var cpu_particles_2d = $"../kill"
@onready var jim = $".."
@onready var audio_stream_player_2d = $"../AudioStreamPlayer2D"
@onready var enemy = $"../emenykill"
@onready var timer = $"../Timer"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	print("goomba stomp")
	cpu_particles_2d.emitting = true
	animated_sprite_2d.scale.y = 0.053
	jim.monitoring = false
	audio_stream_player_2d.play()
	enemy.queue_free()
	timer.start()



func _on_timer_timeout():
	queue_free()
