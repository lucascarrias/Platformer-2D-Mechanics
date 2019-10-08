extends Node

var BLOOD = preload("res://scenes/effects/blood_drop.tscn")

func _ready():
	
	for drop in range(100):
		var blood = BLOOD.instance()
		add_child(blood)
		blood.global_position = get_parent().global_position