extends Node

## as I commented on the Client side script this is mostly stuff I think I'll be
## moving to the NetworkServer script

var Player:PackedScene
var gameManager:Node3D

# a Dictionary of the connected players with the key [Id] and value = Object
var activePlayers = {}
var networkObjects = {}

func _ready() -> void:
	Player = preload("res://scenes/player.tscn")
	gameManager = get_node("/root/GameStateManager")

## when a player disconnects that was previously spawned we need to
## unspawn that player
func deleteClient(ClientId:int):
	# checking if the connected player was spawned, this is necessary because
	# I have it so you can connect to the server before you spawn in
	if activePlayers.has(ClientId) == false:
		return
	var player = activePlayers[ClientId]
	# kill the object then the reference in the Dictionary
	player.queue_free()
	activePlayers.erase(ClientId)
	# we need to tell the rest of the players to delete the guy we just deleted
	for id in activePlayers:
		# id = the client we send the call to, 
		# and ClientId is the Client we are deleting
		c_deletePlayer.rpc_id(id,ClientId)

#region ACTIONS
## bad function name, will be fixing this but
## this is the function that updates a clients position on the server
@rpc("any_peer","unreliable_ordered")
func s_updatePosition(ClientPosition:Vector3):
	# pretty cool line which means we don't have to manually include the id in the rpc call
	var ClientId:int = multiplayer.get_remote_sender_id()
	# get a reference for which object we are moving
	var player = activePlayers[ClientId]
	
	#print(gameManager.get_child(3))
	#print("Client: ",ClientId," At ",NetworkClock.serverTick," is positioned at: ",ClientPosition)
	## simply do the thing, no checks or time stuff just yet
	player.global_position = ClientPosition
	#print(gameManager.find_child(str(ClientId)))
	## we also need to inform the other players connected of the new position of this one
	for id in activePlayers:
		if id != ClientId:
			c_updatePosition.rpc_id(id,ClientPosition,ClientId)

@rpc ("any_peer","reliable")
func s_pingPosition(ClientPos:Vector3,ClientTick:int):
	var ClientId:int = multiplayer.get_remote_sender_id()
	
	var player = activePlayers[ClientId]
	
	c_pongPosition.rpc_id(ClientId,ClientPos,ClientTick,player.get_pos(),NetworkClock.serverTick)
	pass



@rpc ("any_peer","unreliable_ordered")
func s_movePlayer(wish_dir:Vector3):
	#print("THE PLAYER WISHES TO MOVE")
	var ClientId:int = multiplayer.get_remote_sender_id()
	
	var player = activePlayers[ClientId]
	
	player.move(wish_dir)

@rpc ("any_peer","unreliable_ordered")
func s_jump():
	var ClientId:int = multiplayer.get_remote_sender_id()
	
	var player = activePlayers[ClientId]
	
	player.jump()

## spawning player on the server, and then also on the other clients
@rpc ("any_peer", "reliable")
func s_spawnPlayer(Position:Vector3):
	var ClientId:int = multiplayer.get_remote_sender_id()
	print("spawning player on server...")
	var player = Player.instantiate()
	# again we need to add the instance to the scene tree before doing anything
	gameManager.add_child(player)
	player.global_position = Position
	player.set_ID(ClientId)
	
	#print(player)
	## add the new player to the players table
	activePlayers[ClientId] = player
	
	## Spawning all the connected players to the new players client and Spawning 
	## the new player on all the connected players clients
	for id in activePlayers:
		if id != ClientId:
			c_spawnPlayer.rpc_id(ClientId,activePlayers[id].global_position,id)
			c_spawnPlayer.rpc_id(id,activePlayers[ClientId].global_position,ClientId)
		for Id in networkObjects:
			#print(networkObjects)
			var obj = networkObjects[Id]
			c_spawnObject.rpc_id(id,obj.name,obj.TYPE,obj.global_position,obj.sceneId,Id)
	pass
#endregion

#region PARITY
@rpc ("reliable")
func c_spawnPlayer(_Position:Vector3,_Id:int):
	print("spawning player locally: ",_Id)
	pass

@rpc ("reliable")
func c_spawnObject(_name:String,_type:NetworkObject.TYPES,
_position:Vector3,_sceneId:int,_Id:int):pass

@rpc ("reliable")
func c_deletePlayer(_Id:int):pass

@rpc ("unreliable_ordered")
func c_updatePosition(_Position:Vector3,_Id:int):pass

@rpc ("reliable")
func c_pongPosition(_clientPos:Vector3,_clientTick:int,
_serverPos:Vector3,_serverTick:int):pass

#endregion
