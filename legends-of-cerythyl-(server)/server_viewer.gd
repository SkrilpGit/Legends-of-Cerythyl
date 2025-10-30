extends Camera3D

@export var movespeed = 10
@export var mousesens = 1.0

@export var zoomstep = 1
@export var zoommin = 2
@export var zoommax = 10

var paused = false
var velocity = Vector3.ZERO

# the holy trinity:
# one for the input of the movement actions
# one for where the player is looking
# and one to put em all together
var input_dir = Vector2.ZERO
var look_dir : Basis
var wish_dir = Vector3.ZERO

func _physics_process(_delta: float) -> void:
	input_dir = Input.get_vector("move_left","move_right","move_forward","move_back")
	look_dir = Basis(Vector3.UP,rotation.y)
	wish_dir = look_dir*Vector3(input_dir.x,0,input_dir.y)
	
	velocity.x = wish_dir.x * movespeed
	velocity.z = wish_dir.z * movespeed

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and !paused:
		var cam_rot = rotation_degrees
		cam_rot.x = clamp(cam_rot.x - event.relative.y * mousesens, -85,85)
		cam_rot.y += -event.relative.x * mousesens
		rotation_degrees = cam_rot
	
	var action = Inputs.find_action_pressed(event)
	match action:
		"ui_cancel":
			if paused:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				paused = false
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				paused = true
		"move_jump":
			velocity.y += movespeed
		"zoom_in":
			Zoom(true)
		"zoom_out":
			Zoom(false)
			
func Zoom(In: bool) -> void:
	if In and fov > zoommin:
		fov -= zoomstep
	elif !In and fov < zoommax:
		fov += zoomstep
