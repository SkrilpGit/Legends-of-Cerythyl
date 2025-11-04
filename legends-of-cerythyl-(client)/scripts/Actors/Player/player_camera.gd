extends Camera3D

@export var zoomstep = 1
@export var zoommin = 2
@export var zoommax = 10

var player : CharacterBody3D

var wish_pos = Vector3.ZERO
var collide_point = null

var aiming = false

func _ready() -> void:
	wish_pos = position
	player = get_parent().get_parent()

func _physics_process(_delta: float) -> void:
	check_collision()
	position = wish_pos
	if collide_point:
		#print(collide_point)
		position = wish_pos + collide_point

func Zoom(In: bool) -> void:
	if aiming:
		return
	if In and wish_pos.z > zoommin:
		wish_pos.z -= zoomstep
	elif !In and wish_pos.z < zoommax:
		wish_pos.z += zoomstep

func check_collision() -> void:
	collide_point = null
	position = wish_pos
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(player.global_position,global_position,)
	query.collide_with_areas = true
	
	var result = space_state.intersect_ray(query)
	#print(result)
	if result:
		collide_point = Vector3(0,0,to_local(result.position).z)
