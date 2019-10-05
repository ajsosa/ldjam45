extends Area2D

var swarm

var speed = 1.5
var rotSpeed = 0.07

var rot = 0

func _ready():
	speed = rand_range(0.5, 1)
	rotSpeed = rand_range(0.04, 0.07)
	
	rot = rand_range(0, PI * 2)
	swarm = get_parent().get_parent()

func _process(delta):
	var desiredA = -atan2(swarm.getTarget().y - position.y, swarm.getTarget().x - position.x)
	var theta = desiredA - rot
	
	if theta > PI:
		rot += 2 * PI
	elif theta < -PI:
		rot -= 2 * PI
	
	var turnVelo = (desiredA - rot) * rotSpeed
	rot += turnVelo
	
	var c = cos(rot)
	var s = sin(rot)
	
	position.x += c * speed
	position.y -= s * speed
	
	rotation = -rot + PI/2
