extends Node
@onready var point_label = $Label


	
var score = 0



func add_point():
	score += 1 
	point_label.text = "x" + str(score)
	print(score)
	
