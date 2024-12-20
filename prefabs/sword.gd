extends AnimatedSprite2D

@onready var sword_area = $"../../Area2D"

# This function gets called when an enemy enters the sword's area.
 	

func _ready():
	sword_area.connect("body_entered", Callable(self, "_on_sword_area_body_entered"))


func _on_area_2d_body_entered(body):
	if body.is_in_group("enemies"):  # Assuming enemies are in the "enemies" group # Check if the enemy has a 'kill' method
		body.kill()  # Call the kill function on the enemy
	else:
		print("Enemy does not have a 'kill' method!")
	
