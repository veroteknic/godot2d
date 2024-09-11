extends Area2D
@onready var timer = $Timer
@onready var audio_stream_player_2d = $AudioStreamPlayer2D
@onready var cpu_particles_2d = $CPUParticles2D
var player: CharacterBody2D

func _ready():
	Engine.time_scale = 1
	player = get_parent().get_parent().get_parent().get_node("player")
func _on_timer_timeout():
	Engine.time_scale = 0.5
	print("dead")
	get_tree().reload_current_scene()
	
func _on_body_entered(_body):
	print_rich("get rekt haha idiot")
	player.queue_free()
	Engine.time_scale = 1
	cpu_particles_2d.emitting = true
	audio_stream_player_2d.play()
	
	timer.start()

		
