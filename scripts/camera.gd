extends Camera2D

var target
var swarm
const deltaLerp = 0.01

const minZoom = 0.90
const zoomCoeff = 0.0001

func _ready():
	
	current = true
	drag_margin_h_enabled = false
	drag_margin_v_enabled = false
	
	limit_left = 0
	limit_right = 2112
	limit_top = 0
	limit_bottom = 2176
	
	swarm = get_parent().get_node("Swarm")
	var player = get_parent().get_node("Swarm").get_node("Marker")
	
	target = player
	
	var targetPos = getTargetPos()
	position.x = targetPos.x
	position.y = targetPos.y

func _process(delta):
	var targetPos = getTargetPos()
	position = position.linear_interpolate(targetPos, deltaLerp)
	
	adjustZoom()
	align()
	

func adjustZoom():
	var antCount = swarm.swarmStrength
	var zoomAmount = minZoom + (antCount * zoomCoeff)
	zoom = Vector2(zoomAmount, zoomAmount)
	
func getTargetPos():
	#var halfSize = get_viewport().size
	
	#var x = target.position.x + halfSize.x * 0.5
	#var y = target.position.y + halfSize.y * 0.5
	var x = target.get_parent().position.x + target.position.x
	var y = target.get_parent().position.y + target.position.y
	return Vector2(x, y)