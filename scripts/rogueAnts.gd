extends Node

export var antCount = 1

var antObject
var target
var area

var battleCircle

var battling = false
var owned = false

var strength = antCount

var threshold = strength * 0.80

var battleLimit = 5
var battleTimer = 0
var engage = false
var killRate = 0
var dt = 0

var swarm = null

func _ready():
	battleCircle = $BattleCircle
	battleCircle.connect("area_entered", self, "enterBattle") 
	battleCircle.connect("area_exited", self, "leaveBattle") 
	
	antObject = load("res://scenes/Objects/Ant.tscn")
	target = $RogueArea.position
	
	area = $RogueArea
	area.connect("area_entered", self, "entered")
	area.connect("area_exited", self, "exited")
		
	for i in range(antCount):
		addAnt()

func _process(delta):
	dt = delta
	if not owned and battling:
		if threshold > antCount :
			owned = true
			setFriendly()
		else:
			if battleTimer <= battleLimit:
				battleTimer += killRate * delta
			else:
				battleTimer = 0
				kill()
			var center = getCenter()
			battleCircle.position = center
func addAnt():
	var ant = antObject.instance()
	add_child(ant)
	ant.get_node("Area2D").setEnemy()
	
	return ant
	
func getTarget():
	return target
	
func entered(other):
	if other.get_parent().get_name() != "Marker":
		return
	target = other.get_parent()
	killRate = other.get_parent().get_parent().swarmStrength
	other.get_parent().get_parent().killRate = antCount
	swarm = other.get_parent().get_parent()
	
func exited(other):
	if other.get_parent().get_name() != "Marker":
		return
	target = $Area2D.position
	
func enterBattle(other):
	if other.name == "RogueArea":
		return
	battling = true
	pass
	
func leaveBattle(other):
	if other.name == "RogueArea":
		return
	battling = false
	pass
	
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
	
func setFriendly():
	for ant in get_children():
		if ant.get_name() == "RogueArea" or ant.get_name() == "BattleCircle":
			continue
		ant.get_node("Area2D").setFriendly()
		
func getCenter():
	var pos = Vector2.ZERO
	var i = 0
	for ant in get_children():
		if ant.name == "RogueArea" or ant.name == "BattleCircle":
			continue
		pos += ant.get_node("Area2D").position
		i += 1
	
	var avg = pos / i
	return avg