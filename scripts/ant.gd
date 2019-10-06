extends Area2D

var swarm

var speed = 1.5
var rotSpeed = 0.07

var rot = 0
var anim

var killed = false

var baseScale = 1

var offSet = Vector2(rand_range(-50, 50), rand_range(-50, 50))

func _ready():
	speed = rand_range(1.3, 1.7)
	rotSpeed = rand_range(0.007, 0.04)
	
	rot = rand_range(0, PI * 2)
	swarm = get_parent().get_parent()
	
	$Sprite/AnimationPlayer.play("ant_walk");
	$Enemy.visible = false
	anim = $Sprite/AnimationPlayer
	
	anim.connect("animation_finished", self, "exploded")
	$Enemy/AnimationPlayer.connect("animation_finished", self, "exploded")

func setEnemy():
	$Sprite.visible = false
	$Enemy.visible = true
	
	$Sprite/AnimationPlayer.stop()
	$Enemy/AnimationPlayer.play("ant_walk")
	anim = $Enemy/AnimationPlayer
	
func setFriendly():
	$Sprite.visible = true
	$Enemy.visible = false
	
	$Sprite/AnimationPlayer.play("ant_walk")
	$Enemy/AnimationPlayer.stop()
	anim = $Sprite/AnimationPlayer
	
func _process(delta):
	var pos = swarm.getTarget()
	
	if not pos is Vector2:
		if pos.get_name() == "Marker":
			pos = swarm.to_local(pos.global_position)
	
	pos = pos + offSet
	
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
	
	if not killed:
		position.x += c * speed
		position.y -= s * speed
	
	rotation = -rot + PI/2
	
func kill():
	killed = true
	anim.play("explode")
	
func exploded(name):
	if name == "explode":
		self.queue_free()