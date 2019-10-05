extends Camera2D

var target
const deltaLerp = 0.01

func _ready():
	
	current = true
	drag_margin_h_enabled = false
	drag_margin_v_enabled = false
	
	var player = get_parent().get_node("Swarm").get_node("Marker")
	
	target = player
	
	var targetPos = getTargetPos()
	position.x = targetPos.x
	position.y = targetPos.y

func _process(delta):
	
	var targetPos = getTargetPos()
	position = position.linear_interpolate(targetPos, deltaLerp)
	
	align()
	
	print(position)
	

func getTargetPos():
	
	var halfSize = get_viewport().size
	
	var x = target.position.x + halfSize.x * 0.5
	var y = target.position.y + halfSize.y * 0.5
	return Vector2(x, y)





