extends RigidBody2D

func _ready():
	var rand_value = rand_range(0.5,1)
	scale = Vector2(rand_value, rand_value)
	var rand_vel = Vector2(rand_range(-200,200), rand_range(-200,200))
	linear_velocity = rand_vel
	angular_velocity = 15

func _on_fade_out_timeout():
	get_parent().queue_free()
