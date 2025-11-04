class_name NetworkObject extends Node3D

enum TYPES {
	PLAYER,
	NPC,
	OBJECT
}

@export var TYPE: TYPES
@export var sceneId: int
var ID: int

signal IdChanged

func set_ID(id):
	ID = id
	emit_signal("IdChanged",id)
