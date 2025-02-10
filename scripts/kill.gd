extends Area2D

@onready var timer = $Timer
@onready var audio_stream_player_2d = $AudioStreamPlayer2D
@onready var cpu_particles_2d = $CPUParticles2D
@onready var wasted = $wasted  # Not used in the current script?

var player: CharacterBody2D
@export var health = 3

func _ready():
	Engine.time_scale = 1
	player = get_parent().get_parent().get_parent().get_node("player")

func _on_body_entered(_body):
	print_rich("[color=red]get rekt haha idiot[/color]")

	if player and is_instance_valid(player):
		player.queue_free()  # ✅ Ensure player exists before deleting

	# 🎇 Play Effects
	cpu_particles_2d.emitting = true
	audio_stream_player_2d.play()
	
	# 🕒 Slow motion effect
	Engine.time_scale = 0.5  
	
	# 🕒 Start timer before reloading scene
	timer.start()

func _on_timer_timeout():
	print("[color=yellow]Even more dead[/color]")
	Engine.time_scale = 1.0  # ✅ Restore normal game speed
	get_tree().reload_current_scene()  # ✅ Restart the level
