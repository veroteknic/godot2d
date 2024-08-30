extends Area2D
@onready var cpu = $"../cpu"
@onready var animated_sprite_2d = $"../AnimatedSprite2D"
@onready var cpu_particles_2d = $CPUParticles2D
@onready var jim = $"../emenykill"
@onready var enemy = $".."
@onready var timer = $"../Timer"
@onready var audio_stream_player_2d = $"../AudioStreamPlayer2D"



# Called when the node enters the scene tree for the first time.
func _ready():
	animated_sprite_2d.scale.y = 1.153


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	cpu_particles_2d.emitting = true
	cpu.emitting = false
	animated_sprite_2d.scale.y = 0.053
	jim.monitoring = false
	audio_stream_player_2d.play()
	timer.start()



func _on_timer_timeout():
		enemy.queue_free()
