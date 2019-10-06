extends Node

export var antCount = 20
export var isRogue = false

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

var startingAntCount
var antCap
var spawnRate

var spawn = 0
var spawnTimer = 0

var cowardThreshold

var anim

func _ready():
	startingAntCount = antCount
	antCap = antCount
	spawnRate = antCount * 2
	cowardThreshold = antCount * 0.80
	
	battleCircle = $Sprite/BattleCircle/CollisionShape2D
	battleCircle.get_parent().connect("area_entered", self, "enterBattle") 
	battleCircle.get_parent().connect("area_exited", self, "leaveBattle") 
	
	area = $Sprite/MoundRadius
	area.connect("area_entered", self, "entered") 
	area.connect("area_exited", self, "exit") 
	
	antObject = load("res://scenes/Objects/Ant.tscn")
	anim = $Sprite/AnimationPlayer
	if isRogue:
		makeAnts = true
		anim.play("rogue")
	else:
		anim.play("enemy")
		
	target = area.position

func _process(delta):
	dt = delta
	if makeAnts:
		if antCount > 0:
			var ant = addAnt()
			ant.get_node("Area2D").setEnemy()
			antCount -= 1
			
	if owned and not isRogue:
		if spawnTimer <= spawnRate:
			spawnTimer += 2 * delta
			spawn += 1
			
			if spawn > antCap:
				spawn = antCap
		else:
			spawnTimer = 0
	elif battling:
		if engage:
			if isRogue and cowardThreshold > startingAntCount:
				defect()
			else:
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
			if not isRogue:
				swarm.rogueAnts.append(self)
				anim.play("owned")

func addAnt():
	var ant = antObject.instance()
	add_child(ant)
	
	return ant

func entered(other):
	if other.get_parent().get_name() != "Marker":
		return
	
	if owned:
		for i in range(spawn):
			addAnt()
			startingAntCount += 1
			swarm.swarmStrength += 1
			
		spawn = 0
		return
	
	target = other.get_parent()
	makeAnts = true
	battling = true
	if not owned:
		other.get_parent().get_parent().battling = true
	killRate = other.get_parent().get_parent().swarmStrength
	other.get_parent().get_parent().killRate = startingAntCount
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
	
	if isRogue and swarm.swarmStrength >= startingAntCount:
		defect()

func leaveBattle(other):
	if other.get_name() == "MoundRadius":
		return
		
	engage = false
	other.get_parent().get_parent().engage = false
	
func kill():
	if not swarm:
		return
		
	if swarm.get_children().size() == 1 && not owned:
		return
		
	for ant in get_children():
		if ant.name == "Sprite":
			continue	
		ant.queue_free()
		startingAntCount -= 1
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
	
func defect():
	owned = true
	swarm.swarmStrength += startingAntCount
	setFriendly()
	battling = false
	engage = false
	swarm.battling = false
	swarm.rogueAnts.append(self)
	
func setFriendly():
	for ant in get_children():
		if ant.get_name() == "Sprite":
			continue
		ant.get_node("Area2D").setFriendly()