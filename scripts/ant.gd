extends Area2D

var swarm

var speed = 1.5
var rotSpeed = 0.07

var rot = 0

func _ready():
	speed = rand_range(0.8, 1.5)
	rotSpeed = rand_range(0.005, 0.04)
	
	rot = rand_range(0, PI * 2)
	swarm = get_parent().get_parent()
	
	$Sprite/AnimationPlayer.play("ant_walk");
	$Enemy.visible = false

func setEnemy():
	$Sprite.visible = false
	$Enemy.visible = true
	
	$Sprite/AnimationPlayer.stop()
	$Enemy/AnimationPlayer.play("ant_walk")
	
func setFriendly():
	$Sprite.visible = true
	$Enemy.visible = false
	
	$Sprite/AnimationPlayer.play("ant_walk")
	$Enemy/AnimationPlayer.stop()
	
func _process(delta):
	#var others = swarm.getNeighbors(self)
	
	#for other in others:
		#var between = angleBetween(other.position, position)
		#var degree = rad2deg(between)

		#if degree > 100:
			#continue
	
		#var desiredA = -atan2(other.position.y - position.y, other.position.x - position.x)
		#var theta = desiredA - rot
		
		#if theta > PI:
		#	rot += 2 * PI
		#elif theta < -PI:
		#	rot -= 2 * PI
			
		#var turnVelo = (desiredA - rot) * rotSpeed * 0.1
		#rot -= turnVelo
	
	var pos = swarm.getTarget()
	
	if not pos is Vector2:
		if pos.get_name() == "Marker":
			pos = swarm.to_local(pos.global_position)
	
	var desiredA = -atan2(pos.y - position.y, pos.x - position.x)
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

#func angleBetween(v1, v2):
#	var dotMagMag = v1.dot(v2) / (mag(v1) * mag(v2))
#	
#	var angle = acos(min(1, max(-1, dotMagMag)))
#	return angle

#func mag(v):
#	var x = max(abs(v.x), abs(v.y))
#	var y = min(abs(v.x), abs(v.y))
	
#	if x == 0:
#		return 1
	
#	var t = y / x
#	return x * sqrt(1 + t * t)