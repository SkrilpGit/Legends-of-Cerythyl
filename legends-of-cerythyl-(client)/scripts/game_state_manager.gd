extends Node3D

var main_menu = "uid://s863em6ask7b" ## main_menu.tscn UID
var player = CharacterBody3D

func _ready() -> void:
	player = find_child("Player")
	## Initialise the gameManager variable in the NetworkActions Script
	NetworkActions.gameManager = self
	NetworkClock.requestingPing.connect(pingPosition)
	## Make sure we do something when we get disconnected from the server
	NetworkServer.disconnected_from_server.connect(_on_disconnection)

## for now we are booting back to the Main Menu
func _on_disconnection() -> void:
	var path = ResourceUID.uid_to_path(main_menu)
	get_tree().change_scene_to_file(path)

func pingPosition():
	NetworkActions.s_pingPosition.rpc_id(1,player.global_position,NetworkClock.clientTick)

func check_position(clientPos,clientTick,serverPos,serverTick) -> void:
	var dif_tick = serverTick - clientTick
	var move_offset = player.movespeed*NetworkClock.SEC_PER_FRAME
	var dif_pos = Vector3(serverPos - clientPos).length() * move_offset
	
	print("dif_tick: ",dif_tick," dif_pos: ",dif_pos," difference: ", dif_pos - dif_tick)
	dif_pos = round(dif_pos)
	
	if dif_pos > abs(dif_tick):
		player.global_position = serverPos
		print("resynching...")
	pass
