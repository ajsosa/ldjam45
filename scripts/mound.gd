extends Node

export var antCount = 20
export var isRogue = false
export var isQueen = false
export var isSandCastle = false
export var willDefect = true

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

var ants = []

var queenSpawned = false
var queenHealth = 500

var audio

func _ready():
	startingAntCount = antCount
	antCap = antCount + antCount * 0.75
	spawnRate = antCount * 2
	cowardThreshold = antCount * 0.80
	
	battleCircle = $Sprite/BattleCircle/CollisionShape2D
	battleCircle.get_parent().connect("area_entered", self, "enterBattle") 
	battleCircle.get_parent().connect("area_exited", self, "leaveBattle") 
	
	area = $Sprite/MoundRadius
	area.connect("area_entered", self, "entered") 
	area.connect("area_exited", self, "exit")
	
	audio = $AudioStreamPlayer2D
	
	antObject = load("res://scenes/Objects/Ant.tscn")
	anim = $Sprite/AnimationPlayer
	if isRogue:
		makeAnts = true
		anim.play("rogue")
	else:
		anim.play("enemy")
		
	target = area.position

func _process(delta):
	if isQueen:
		if swarm:
			swarm.battling = true
		battling = true
	dt = delta
	if makeAnts:
		if antCount > 0:
			var ant = addAnt()
			ant.get_node("Area2D").setEnemy()
			antCount -= 1
			
	if owned and not isRogue:
		pass
	elif not owned and battling:
		if engage:
			swarm.engage = true
			swarm.battling = true
			killRate = swarm.swarmStrength
			if not queenSpawned:
				swarm.killRate = startingAntCount
			if willDefect and isRogue and cowardThreshold > startingAntCount:
				defect()
			else:
				if battleTimer <= battleLimit:
					battleTimer += killRate * delta
				else:
					battleTimer = 0
					kill()
					if startingAntCount <= 0 and not queenSpawned:
						swarm.engage = false
						swarm.battling = false
						owned = true
						
						audio.play()
						
						if not isRogue:
							swarm.rogueAnts.append(self)
							anim.play("owned")
							spawn = antCap
							
		var center = getCenter()
		battleCircle.get_parent().position = center
	
	if spawn and not isQueen:
		if owned and not isRogue and not isSandCastle:
			for i in range(spawn):
				addAnt()
				startingAntCount += 1
				swarm.swarmStrength += 1
			spawn = 0
	
	if spawn and isQueen:
		var ant = addAnt()
		ant.get_node("Area2D").setEnemy()
		ant.get_node("Area2D").set_scale(Vector2(15, 15))
		queenSpawned = true
		spawn = 0
		battling = true
		engage = true
		swarm.battling = true
		swarm.engage = true
		owned = false
		swarm.killRate = 200

func addAnt():
	var ant = antObject.instance()
	add_child(ant)
	ants.append(ant)
	
	return ant

func entered(other):
	if other.get_parent().get_name() != "Marker":
		return
	if owned:
		return
	
	target = other.get_parent()
	makeAnts = true
	battling = true
	if not owned:
		other.get_parent().get_parent().battling = true
	killRate = other.get_parent().get_parent().swarmStrength
	other.get_parent().get_parent().killRate = startingAntCount
	swarm = other.get_parent().get_parent()
	
func exit(other):
	if other.get_parent().get_name() != "Marker":
		return
	
	if owned:
		return
	
	makeAnts = false
	target = area.position
	battling = false
	other.get_parent().get_parent().battling = false
	
func enterBattle(other):
	if other.get_name() == "MoundRadius":
		return
		
	if owned:
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
	
	var killQueen = false	
	if queenSpawned:
		queenHealth -= 1
		if queenHealth <= 0:
			audio.play()
			owned = true
			swarm.killRate = 0
			swarm.engage = false
			swarm.battling = false
			
			var endScreenNode = get_tree().get_root().get_node("TestLevel/CanvasLayer/EndScreen")
			endScreenNode.visible = true
		else:
			return
		
	var killedAnt = null
	for ant in ants:
		ant.get_node("Area2D").kill()
		startingAntCount -= 1
		killedAnt = ant
		break
		
	if killedAnt:
		ants.erase(killedAnt)

func getTarget():
	return target
	
func getCenter():
	var pos = Vector2.ZERO
	var i = 0
	for ant in ants:
		pos += ant.get_node("Area2D").position
		i += 1
	if i == 0:
		return Vector2.ZERO
	
	var avg = pos / i
	return avg
	
func defect():
	owned = true
	swarm.swarmStrength += startingAntCount
	setFriendly()
	battling = false
	engage = false
	swarm.battling = false
	swarm.engage = false
	swarm.rogueAnts.append(self)
	audio.play()
	
func setFriendly():
	for ant in ants:
		ant.get_node("Area2D").setFriendly()