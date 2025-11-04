extends CharacterBody3D

@export var movespeed = 10
@export var jumpforce = 10
@export var mousesens = 1.0
@export var gravity = 10

var prev_pos = Vector3.ZERO
var wish_dir = Vector3.ZERO
var ourId: int

func _ready():
	prev_pos = global_position
	get_parent().connect("IdChanged",update_Id)

func _physics_process(_delta: float) -> void:
	
	#ourId = get_parent().ID
	
	velocity.x = wish_dir.x * movespeed
	velocity.z = wish_dir.z * movespeed
	
	if !is_on_floor() and velocity.y > -100:
		velocity.y -= gravity * _delta
	
	move_and_slide()
	
	for id in NetworkActions.activePlayers:
		#print(get_parent().ID)
		if id != ourId:
			NetworkActions.c_updatePosition.rpc_id(id,global_position,ourId)
	
	prev_pos = global_position
	wish_dir = Vector3.ZERO

func update_Id(id):
	ourId = id

func move(dir):
	print(dir)
	wish_dir = dir

func jump() -> void:
	velocity.y += jumpforce
