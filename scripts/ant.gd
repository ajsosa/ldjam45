extends Area2D

var swarm

var speed = 200
var rotSpeed = 50

var velo = Vector2.ZERO
var accel = Vector2.ZERO

func _ready():
	rotation += rand_range(-0.09, 0.09)
	velo = transform.x * speed
	
	swarm = get_parent().get_parent()
	pass

func _process(delta):
	accel += seek()
	velo += accel * delta
	velo = velo.clamped(speed)
	rotation = velo.angle()
	position += velo * delta

func seek():
	var steer = Vector2.ZERO
	if swarm:
		var desired = (swarm.getTarget() - position).normalized() * speed
		steer = (desired - velo).normalized() * rotSpeed

	return steer