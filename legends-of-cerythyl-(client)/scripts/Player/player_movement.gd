extends CharacterBody3D

## Simple player movement script designed to work on a CharacterBody3D
## I'm also calling some network actions in here so we need to keep track of that

@export var movespeed = 10
@export var jumpforce = 10
@export var mousesens = 1.0
@export var gravity = 10

# for solving camera movement vs character movement there are plenty of strategies
# the one I'm employing in this script rn is have a pivot Node3D that parents
# the camera allowing us to change the pivot rotation but keep a consistent distance
# from the camera to the player
var campivot : Node3D
var cam : Camera3D
var paused = false

# the holy trinity:
# one for the input of the movement actions
# one for where the player is looking
# and one to put em all together
var input_dir = Vector2.ZERO
var look_dir : Basis
var wish_dir = Vector3.ZERO
var prev_pos = Vector3.ZERO

func _ready() -> void:
	campivot = find_child("CameraPivot")
	cam = campivot.find_child("Camera")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	var prev_pos = global_position
	
	# telling the server to spawn in our player, lets goooooo
	NetworkActions.s_spawnPlayer.rpc_id(1,global_position)

func _physics_process(_delta: float) -> void:
	input_dir = Input.get_vector("move_left","move_right","move_forward","move_back")
	look_dir = Basis(Vector3.UP,campivot.rotation.y)
	wish_dir = look_dir*Vector3(input_dir.x,0,input_dir.y)
	
	if wish_dir != Vector3.ZERO:
		NetworkActions.s_movePlayer.rpc_id(1,wish_dir)
	
	velocity.x = wish_dir.x * movespeed
	velocity.z = wish_dir.z * movespeed
	
	if !is_on_floor() and velocity.y > -100:
		velocity.y -= gravity * _delta
	
	move_and_slide()
	
	#if global_position != prev_pos:
		#_sendPosition()
		##print("SENDING POSITION TO SERVER")
	#
	#prev_pos = global_position

## input handling is always fun, for this script I've also included a cool match
## case solution for actions, the complicated stuff is in the Inputs Singleton
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and !paused:
		var cam_rot = campivot.rotation_degrees
		cam_rot.x = clamp(cam_rot.x - event.relative.y * mousesens, -85,85)
		cam_rot.y += -event.relative.x * mousesens
		campivot.rotation_degrees = cam_rot
	
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
			if is_on_floor():
				velocity.y += jumpforce
				NetworkActions.s_jump.rpc_id(1)
		"zoom_in":
			cam.Zoom(true)
		"zoom_out":
			cam.Zoom(false)

## whenever our position changes between physics ticks, we update our player
## position with the server.
func _sendPosition():
	NetworkActions.s_updatePosition.rpc_id(1,global_position)
	#print("At ",NetworkClock.clientTick," I was at ",global_position)
