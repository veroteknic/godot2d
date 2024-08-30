extends Node

signal button_pressed
@onready var example_label = %example_label


func _ready():
	#you can turn on linewrap in the editor's code setting to make long strings easier to read
	#--------------------------------------
	_set_example_text("")
	
	
	await button_pressed
	_set_example_text("[rainbow]text[/rainbow]")
	print("")
	print_rich("[rainbow freq=1.0 sat=0.8 val=0.8]WOW good programming work!! Your janky code actually works somehow lol[/rainbow]")
	print("")
	print_rich("[img=160x160]res://funny_cat.tres")
	print_rich("[font_size=30][wave amp=50.0 freq=-5.0 connected=1][color=CORNFLOWER_BLUE]nice animation testing[/color][/wave][/font_size]")
func _set_example_text(text : String):
	example_label.text = "print_rich(\"" + text + "\")"
	#  \" lets you have quotes in strings (see "escape character strings")

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		emit_signal("button_pressed")
