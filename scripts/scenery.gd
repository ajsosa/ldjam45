extends Node

export var antScaleFactor = 1.0

func _ready():
	pass
#	$Sprite/Area2D.connect("area_entered", self, "entered")
#	$Sprite/Area2D.connect("area_exited", self, "exited")
	
#func entered(other):
#	if other.get_parent().name == "Marker":
#		return
#	var current = other.scale
#	var newScale = current.x * antScaleFactor
#	other.set_scale(Vector2(newScale, newScale))

#func exited(other):
#	if other.get_parent().name == "Marker":
#		return
#	other.set_scale(Vector2(other.baseScale, other.baseScale))