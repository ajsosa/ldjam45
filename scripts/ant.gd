extends Area2D

var swarm

var speed = 1.5
var rotSpeed = 0.07

var rot = 0
var anim

var killed = false

var baseScale = 1

var offSet = Vector2(rand_range(-50, 50), rand_range(-50, 50))

var audio

var scenery = []

func _ready():
	speed = rand_range(1.3, 1.7)
	rotSpeed = rand_range(0.007, 0.04)
	
	rot = rand_range(0, PI * 2)
	swarm = get_parent().get_parent()
	
	audio = $AudioStreamPlayer2D
	
	$Sprite/AnimationPlayer.play("ant_walk");
	$Enemy.visible = false
	anim = $Sprite/AnimationPlayer
	
	anim.connect("animation_finished", self, "exploded")
	$Enemy/AnimationPlayer.connect("animation_finished", self, "exploded")
	
	var sceneryNode = get_tree().get_root().get_node("TestLevel/Scenery")
	var logs = sceneryNode.get_node("Logs")
	var rocks = sceneryNode.get_node("Rocks")
	collectScenery(logs)
	collectScenery(rocks)

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
	checkScenery()

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
	audio.play()
	anim.play("explode")
	
func exploded(name):
	if name == "explode":
		self.queue_free()
		
func collectScenery(node):		
	for child in node.get_children():
		var logSprite = child.get_node("Sprite")
		var shape2D = logSprite.get_node("Area2D/CollisionShape2D")
		var shape = shape2D.get_shape()
		var gX = shape2D.global_position.x
		var lhs = gX - (child.scale.x * shape.extents.x)
		var rhs = gX + (child.scale.x * shape.extents.x)
		var gY = shape2D.global_position.y
		var ts = gY - (child.scale.y * shape.extents.y)
		var bs = gY + (child.scale.y * shape.extents.y)
		
		var entry = []
		entry.append(Vector2(lhs, rhs))
		entry.append(Vector2(ts, bs))
		scenery.append(entry)
		
func checkScenery():
	var sPosX = global_position.x
	var sPosY = global_position.y
	
	var scaleSet = false
	for obj in scenery:
		var sides = obj[0]
		var tops = obj[1]
		
		if sPosX > sides.x and sPosX < sides.y and sPosY > tops.x and sPosY < tops.y:
			$Sprite.set_scale(Vector2(1.5, 1.5))
			$Enemy.set_scale(Vector2(1.5, 1.5))
			scaleSet = true
			break
			
	if not scaleSet:
		$Sprite.set_scale(Vector2(1, 1))
		$Enemy.set_scale(Vector2(1, 1))