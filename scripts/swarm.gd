extends Node

export var swarmCount = 1

var antObject
var target = Vector2.ZERO

var marker
var sight = 10

var battling = false

var battleLimit = 5
var battleTimer = 0
var engage = false
var dt = 0

var killRate = 0

var swarmStrength = swarmCount

var quake = load("res://scripts/quake.gd").new()

var rogueAnts = []

func _ready():
	antObject = load("res://scenes/Objects/Ant.tscn")
	
	for i in range(swarmCount):
		var ant = antObject.instance()
		add_child(ant)
		
	marker = $Marker
	
	quake.registerCamera(get_parent().get_node("Camera2D"))

func _exit_tree():
    quake.free()

func _process(delta):
	quake.update(delta)
	dt = delta
	if Input.is_action_pressed("addAnt"):
		addAnt()
	
	if Input.is_action_pressed("down"):
		target.y += 70 * delta
	elif Input.is_action_pressed("up"):
		target.y -= 70 * delta
		
	if Input.is_action_pressed('right'):
		target.x += 70 * delta
	elif Input.is_action_pressed('left'):
		target.x -= 70 * delta
	
	marker.position = target
	
	if battling:
		if engage:
			if battleTimer <= battleLimit:
				battleTimer += killRate * dt
			else:
				battleTimer = 0
				kill()

func kill():
	var killed = false
	for ant in get_children():
		if ant.name == "Marker":
			continue	
		ant.queue_free()
		quake.start(9, 0.2)
		killed = true
		break
	if not killed:
		for rogue in rogueAnts:
			if rogue.startingAntCount == 0:
				continue
			rogue.kill()
			swarmStrength -= 1
			killed = true
			break
			
	if not killed:
		get_tree().reload_current_scene()

func addAnt():
	var ant = antObject.instance()
	add_child(ant)
	swarmStrength += 1

func getNeighbors(target):
	var others = []
	
	for ant in get_children():
		if ant.name == "Marker":
			continue
		if target == ant:
			continue
		
		if overlaps(ant.get_node("Area2D").position, 3, target.position, sight):
			others.append(ant)
			
	return others
	
func getTarget():
	return target
	
func overlaps(c1, r1, c2, r2):
	return dist(c1, c2) <= r1 + r2
	
func dist(c1, c2):
	var dx = c1.x - c2.x
	var dy = c1.y - c2.y
	
	return sqrt(dx * dx + dy * dy)