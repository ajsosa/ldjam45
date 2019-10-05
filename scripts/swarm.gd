extends Node

export var swarmCount = 1

var antObject
var target = Vector2.ZERO

var marker

func _ready():
	antObject = load("res://scenes/Objects/Ant.tscn")
	
	for i in range(swarmCount):
		var ant = antObject.instance()
		add_child(ant)
		
	marker = $Marker


func _process(delta):
	if Input.is_action_pressed("down"):
		target.y += 50 * delta
	elif Input.is_action_pressed("up"):
		target.y -= 50 * delta
		
	if Input.is_action_pressed('right'):
		target.x += 50 * delta
	elif Input.is_action_pressed('left'):
		target.x -= 50 * delta
	
	marker.position = target

func addAnt():
	var ant = antObject.instance()
	add_child(ant)

func getNeighbors(target):
	for ant in get_children():
		pass
	
func getTarget():
	return target