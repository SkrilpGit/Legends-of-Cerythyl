extends Node

## so far this script is just stuff that I probably want to move to the
## NetworkServer script tbh

var netPlayer:PackedScene
## this node is being defined elsewhere when the Client loads into the game
var gameManager:Node3D

## table of "network players" players that aren't the Client
var netPlayers = {}

func _ready() -> void:
	## statically typed will create an issue when the network_player scene is
	## changed to something else
	netPlayer = preload("res://scenes/network_player.tscn")

#region ACTIONS

## sends the local Players position to the server to update there
@rpc ("any_peer","unreliable_ordered")
func s_updatePosition(_ClientPosition:Vector3):
	print("sending position to server...")
	pass

## spawns a player locally from the server, will run as a reply from the server
## for every player that is connected to the server, until I start chunking stuff
@rpc ("reliable")
func c_spawnPlayer(Position:Vector3,Id:int):
	print("spawning: ",Id," at ",Position)
	#instantiating a network player instance
	var player = netPlayer.instantiate()
	## when instancing we need to add the instance to the scene tree first
	## before doing anything to it to avoid an error
	gameManager.add_child(player)
	player.global_position = Position
	#giving them the name of their rpc id
	player.name = str(Id)
	#adding the new player into the table of network players
	netPlayers[Id] = player
	

## update the position of a network player locally, reliable means we check to
## make sure the packets are recieved, might change this to unreliable later.
@rpc ("reliable")
func c_updatePosition(Position:Vector3,Id:int):
	# finding the relevant player within the netPlayers Dictionary and updating
	# the object to the new position, very crude but that's where we are rn
	var player = netPlayers[Id]
	player.global_position = Position

## delete a network player locally
@rpc ("reliable")
func c_deletePlayer(Id:int):
	print("Deleting ",Id)
	#assigning a local variable because reasons
	var player = netPlayers[Id]
	#freeing the object of the player
	player.queue_free()
	#deleting the reference in the network player table
	netPlayers.erase(Id)
	pass

## spawning the local Player on the server, this type of function is what we call
## a parity function, in order for rpc functions to do they thing, a function with
## the same name and parameters needs to be present on both the client and server
## so basically this side of the function does nothing, the s_ stands for server
## above I used c_ to reference its a client function, keeping this convention
## will be helpful going forward.
@rpc ("any_peer", "reliable")
func s_spawnPlayer(_Position:Vector3):
	print("spawn player on server...")
	pass

#endregion
