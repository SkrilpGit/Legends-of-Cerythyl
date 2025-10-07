extends Node

## Welcome to the NetworkServer here we will be starting our server and tracking
## our connected clients

#Server Script
## more exported variables on a singleton, weird
@export var port:int = 1032

@export var maxPlayers:int = 2

# bool for whether we are running headless, meaning on the command line with no
# window rendering, we might want to not render things if this is true
var runningHeadless:bool = false

## another weird isConnected bool, though I'm not sure I really care about this
## side of the connection tbh, if the server isn't connected, that would be interesting
var isConnected:bool:
	get:
		var value:int = multiplayer.multiplayer_peer.get_connection_status()
		var ok:int = MultiplayerPeer.ConnectionStatus.CONNECTION_CONNECTED
		return value == ok

## initialising the network peer using ENet
var network = ENetMultiplayerPeer.new()

## here we have an array of clients, I'm not sure if I actually like this though
## I would rather have a table with ids and objects I think, but this just stores
## ids pretty sure so hmm.
var connectedClients:PackedInt32Array:
	get: return multiplayer.get_peers()

## pretty interesting variable to store globally
var connectedClientCount:int:
	get: return connectedClients.size()

## imagining we were running a lobby system tracking this would be a good idea
var clientReadyCount:int = 0

#region LOGIC

## complicated reading below
func _ready() -> void:
	startServer()

#SERVER SETUP

func startServer():
	print(
		"Server: Starting server on ",
		IP.get_local_addresses()[0],
		" : ", port
	)
	
	print(
		"Server: Players required for game: ",
		maxPlayers
	)
	
	## using the create_server() function of an ENetMultiplayer peer to take over the world,
	## or maybe we're just making a server who knows?
	network.create_server(port, maxPlayers)
	
	## setting the multiplayer peer on the multiplayer attribute to the new server
	multiplayer.multiplayer_peer = network
	
	## cool signals
	network.connect("peer_connected", self._peerConnected)
	network.connect("peer_disconnected", self._peerDisconnected)

## literally does nothing right now, which is fine I guess, I mean we actually don't want
## to do anything before the player is loading into the game rn so.
func _peerConnected(connectedClientId:int):
	
	print(
		"Server: User ",
		str(connectedClientId),
		" connected to lobby (",
		len(connectedClients),
		" online)."
	)
	
	if len(connectedClients) == maxPlayers:
		print("Server: Game full, switching to lobby screen.")
		#TODO

## pretty cool function, we trigger the deleteClient function from here :3
func _peerDisconnected(disconnectedClientId:int):
	
	print(
		"Server: User ",
		str(disconnectedClientId),
		" disconnected (",
		len(connectedClients),
		" online)."
	)
	
	NetworkActions.deleteClient(disconnectedClientId)

#endregion
