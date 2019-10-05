extends Node

export var swarmCount = 1

var antObject
var target = Vector2.ZERO

var marker

var sight = 10

func _ready():
	antObject = load("res://scenes/Objects/Ant.tscn")
	
	for i in range(swarmCount):
		var ant = antObject.instance()
		add_child(ant)
		
	marker = $Marker


func _process(delta):
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

func addAnt():
	var ant = antObject.instance()
	add_child(ant)

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