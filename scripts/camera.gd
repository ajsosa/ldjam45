extends Camera2D

var target

func _ready():
	current = true
	drag_margin_h_enabled = false
	drag_margin_v_enabled = false
	
	var player = get_parent().get_node("Swarm")
	
	target = player
	
	limit_left = 0
	limit_right = 1000
	limit_top = 0
	limit_bottom = 240
	var targetPos = getTargetPos()
	position.x = targetPos.x
	position.y = targetPos.y

func _process(delta):
	var targetPos = getTargetPos()
	position.x = targetPos.x
	position.y = targetPos.y

func getTargetPos():
	var x = target.get_parent().position.x + target.position.x
	var y = target.get_parent().position.y + target.position.y
	return Vector2(x, y)
