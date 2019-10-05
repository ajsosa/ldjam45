extends Node

export var antCount = 20
var antCap = antCount
var owned = false

var antObject
var target
var makeAnts = false

var battling = false
var battleCircle

var area

var battleLimit = 5
var battleTimer = 0
var engage = false
var dt = 0

var killRate = 0

var swarm = null

var spawn = 0
var spawnTimer = 0
var spawnRate = antCount * 2

func _ready():
	battleCircle = $Sprite/BattleCircle/CollisionShape2D
	battleCircle.get_parent().connect("area_entered", self, "enterBattle") 
	battleCircle.get_parent().connect("area_exited", self, "leaveBattle") 
	
	area = $Sprite/MoundRadius
	area.connect("area_entered", self, "entered") 
	area.connect("area_exited", self, "exit") 
	
	antObject = load("res://scenes/Objects/Ant.tscn")

func _process(delta):
	dt = delta
	if makeAnts:
		if antCount > 0:
			addAnt()
			swarm.swarmStrength += 1
			antCount -= 1
			
	if owned:
		if spawnTimer <= spawnRate:
			spawnTimer += 2 * delta
			spawn += 1
			
			if spawn > antCap:
				spawn = antCap
		else:
			spawnTimer = 0
	elif battling:
		if engage:
			if battleTimer <= battleLimit:
				battleTimer += killRate * delta
			else:
				battleTimer = 0
				kill()
		var center = getCenter()
		battleCircle.get_parent().position = center
	
	if makeAnts:
		if get_children().size() == 1:
			owned = true

func addAnt():
	var ant = antObject.instance()
	add_child(ant)

func entered(other):
	if other.get_parent().get_name() != "Marker":
		return
	
	if owned:
		for i in range(spawn):
			addAnt()
			
		spawn = 0
		return
	
	target = other.get_parent()
	makeAnts = true
	battling = true
	other.get_parent().get_parent().battling = true
	killRate = other.get_parent().get_parent().swarmStrength
	other.get_parent().get_parent().killRate = antCount
	swarm = other.get_parent().get_parent()
	#battleCircle.disabled = false
	
func exit(other):
	if other.get_parent().get_name() != "Marker":
		return
	
	if owned:
		return
	
	makeAnts = false
	target = area.position
	battling = false
	other.get_parent().get_parent().battling = false
	#battleCircle.disabled = true
	
func enterBattle(other):
	if other.get_name() == "MoundRadius":
		return
	
	engage = true
	other.get_parent().get_parent().engage = true

func leaveBattle(other):
	if other.get_name() == "MoundRadius":
		return
		
	engage = false
	other.get_parent().get_parent().engage = false
	
func kill():
	if not swarm:
		return
		
	if swarm.get_children().size() == 1:
		return
		
	for ant in get_children():
		if ant.name == "Sprite":
			continue	
		ant.queue_free()
		break

func getTarget():
	return target
	
func getCenter():
	var pos = Vector2.ZERO
	var i = 0
	for ant in get_children():
		if ant.name == "Sprite":
			continue
		pos += ant.get_node("Area2D").position
		i += 1
	
	var avg = pos / i
	return avg