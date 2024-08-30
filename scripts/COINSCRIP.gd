extends Area2D

@onready var audio_stream_player = $AudioStreamPlayer
@onready var game_manager = $"../../GameManager"
@onready var animated_sprite_2d = $AnimatedSprite2D

func _on_body_entered(_body):
	var tween = create_tween()
	print("+1 coin!")
	game_manager.add_point()
	audio_stream_player.play()
	tween.tween_property(self, "position", position + Vector2(0, -100), 0.2)
	tween.tween_property(self, "modulate:a", 0.5, 0.1)
	tween.tween_callback(self.queue_free)
	await audio_stream_player.finished
