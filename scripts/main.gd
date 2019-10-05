extends Node

var title = "Antixander the Great"

var fullscreen = false

var oldPosition

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(delta):
	OS.set_window_title(title + " | fps: " + str(Engine.get_frames_per_second()))
	
	if(Input.is_action_just_pressed('fullscreen')):
		if(OS.get_name() == "Windows"):
			OS.window_fullscreen = !OS.window_fullscreen
		else:
			OS.window_borderless = !OS.window_borderless
			
			if(!fullscreen):
				oldPosition = OS.get_window_position()
				
				OS.set_window_size(OS.get_screen_size())
				OS.set_window_position(Vector2())
			elif(fullscreen):
				OS.set_window_size(Vector2(1024, 600))
				OS.set_window_position(oldPosition)
				
			fullscreen = !fullscreen

	if(Input.is_action_just_pressed('quit')):
		get_tree().quit()