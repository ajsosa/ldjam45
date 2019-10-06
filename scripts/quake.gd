extends Node

var intensity = 0
var timer = 0

var view
var globalTrans

var cam

func _ready():
	pass
	
func registerCamera(camera):
	cam = camera
	view = camera.get_viewport()
	globalTrans = view.get_global_canvas_transform()

func start(intensity, duration):
	stop()
	self.intensity = intensity * cam.zoom.x
	timer = duration
	
func stop():
	intensity = 0
	timer = 0
	#view.set_global_canvas_transform(globalTrans)

func update(delta):
	if(!(timer > 0)):
		return
	
	timer -= delta
	if(timer <= 0):
		stop()
	else:
		var val = rand_range(-1.0, 1.0) * intensity
		cam.set_offset(Vector2(val, val))
		#var x = rand_range(0, 100) * 0.01 * intensity
		#var y = rand_range(0, 100) * 0.01 * intensity
		#var new = Transform2D(Vector2(1, 0), Vector2(0, 1), Vector2(x, y))
		#view.set_global_canvas_transform(new)
