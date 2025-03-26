extends Area2D

@onready var timer = $Timer
@onready var audio_stream_player_2d = $AudioStreamPlayer2D
@onready var cpu_particles_2d = $CPUParticles2D
@onready var wasted = $wasted 

var player: CharacterBody2D
@export var health = 3

func _ready():
	Engine.time_scale = 1
	player = get_parent().get_node("playerchar")

func _on_body_entered(_body):
	print_rich("[color=red]get rekt haha idiot[/color]")
	if player and is_instance_valid(player):
		player.queue_free() 
	cpu_particles_2d.emitting = true
	audio_stream_player_2d.play()
	Engine.time_scale = 0.5  
	timer.start()

func _on_timer_timeout():
	print_rich("[color=yellow]Even more dead[/color]")
	Engine.time_scale = 1.0  
	get_tree().reload_current_scene()  
