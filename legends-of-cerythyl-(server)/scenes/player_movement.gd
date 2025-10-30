extends CharacterBody3D

@export var movespeed = 10
@export var jumpforce = 10
@export var mousesens = 1.0
@export var gravity = 10

var prev_pos = Vector3.ZERO
var wish_dir = Vector3.ZERO

func _ready():
	prev_pos = global_position

func _physics_process(_delta: float) -> void:
	
	velocity.x = wish_dir.x * movespeed
	velocity.z = wish_dir.z * movespeed
	
	if !is_on_floor() and velocity.y > -100:
		velocity.y -= gravity * _delta
	
	move_and_slide()
	
	for id in NetworkActions.activePlayers:
		if id != int(name):
			NetworkActions.c_updatePosition.rpc_id(id,global_position,int(name))
	
	prev_pos = global_position
	wish_dir = Vector3.ZERO

func move(dir):
	print(dir)
	wish_dir = dir

func jump() -> void:
	velocity.y += jumpforce
