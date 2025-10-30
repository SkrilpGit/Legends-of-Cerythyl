extends Node3D

var main_menu = "uid://s863em6ask7b" ## main_menu.tscn UID

func _ready() -> void:
	## Initialise the gameManager variable in the NetworkActions Script
	NetworkActions.gameManager = self
	## Make sure we do something when we get disconnected from the server
	NetworkServer.disconnected_from_server.connect(_on_disconnection)

## for now we are booting back to the Main Menu
func _on_disconnection() -> void:
	var path = ResourceUID.uid_to_path(main_menu)
	get_tree().change_scene_to_file(path)
