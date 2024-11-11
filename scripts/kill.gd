extends Area2D
@onready var timer = $Timer
@onready var audio_stream_player_2d = $AudioStreamPlayer2D
@onready var cpu_particles_2d = $CPUParticles2D
@onready var wasted = $wasted

var player: CharacterBody2D
@export var health = 3
func _ready():
	Engine.time_scale = 1
	player = get_parent().get_parent().get_parent().get_node("player")

func _on_body_entered(_body):
	print_rich("get rekt haha idiot")
	timer.start()
	if player and is_instance_valid(player):
		player.queue_free()
	Engine.time_scale = 1
	cpu_particles_2d.emitting = true
	audio_stream_player_2d.play()
	Engine.time_scale = 0.5
	print("dead")
func _on_timer_timeout():
	print("even more deada")
	print("nada")
	
	get_tree().reload_current_scene()
	
