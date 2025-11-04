extends Node3D

func _ready() -> void:
	print("Game Manager Online")

func addNetObject(object:NetworkObject):
	NetworkActions.networkObjects[object.ID] = object

func deleteNetObject(id):
	NetworkActions.networkObjects.erase(id)
