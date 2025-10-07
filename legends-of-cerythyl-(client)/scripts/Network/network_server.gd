extends Node
# Welcome to the NetworkServer Singleton / Autoload, enjoy your stay <3
#Client Script

# some cool exported variables that I have no Idea how to set in the editor :3
@export var port:int = 1032
@export var IP_ADDRESS:String = "localhost"

#weird signals that should be redundant because we have a isConnected boolean
#also weird because in NetworkActions I'm using these even though I can call
#networkAction functions from here because its also a singleton
signal connected_to_server
signal disconnected_from_server

## returns true at the start of the program before an attempt to connect to the
## server is made, bad bad bad
var isConnected:bool:
	get:
		var value:int = multiplayer.multiplayer_peer.get_connection_status()
		var ok:int = MultiplayerPeer.ConnectionStatus.CONNECTION_CONNECTED
		return value == ok

var ownId:int = -1

# we out here using ENet because its cool and stuff, hell yea!
var network: ENetMultiplayerPeer

#region LOGIC

func _ready() -> void:
	#connectToIP(IP_ADDRESS)
	pass

## Connecting to an IP, maybe should include a port aswell if we are being cool
## though statically typing the port is not a bad idea either
func connectToIP(atIP: String):
	## checking if the port is invalid, if the IP is 0 or null 
	## it connects to localhost which is cool
	if port <1 or port >65535 or port == null:
		print("failed to connect to desired port")
		return
	# creating a multiplayer peer based on ENet, we do this every attempt
	# because it stops annoying errors when we try to connect signals that
	# are already connected
	network = ENetMultiplayerPeer.new()
	# instancing a network Client, targeting the desired server IP and port
	network.create_client(atIP, port)
	
	# setting the multiplayer peer to network, I believe its important that this
	# happens after creating a client because it throughs an error when "network"
	# isn't connecting or connected
	multiplayer.multiplayer_peer = network
	
	# if we get here it means we are setup I guess, we don't actually know if
	# we've connected yet though
	print("Client: Activated multiplayer instance.")
	
	# so an ENetMultiplayerPeer has some signals that we would like to pay
	# attention to, could be useful, interesting to note that if you aren't 
	# creating a new network when you call this function, this will through an
	# error because we will have already assigned these signals.
	network.connect("peer_connected", _peerConnected)
	network.connect("peer_disconnected", _peerDisconnected)

## this is a function to manually disconnect from the server, pretty good idea
## if you ask me
func disconnectFromServer():
	# when the client manually disconnects we reset the clock, but if we drop out
	# that might not be the case, doesn't really matter, because to clock tries
	# to sync itself anyway, but if we want it to track the current unbroken
	# session, will have to change eventually
	NetworkClock.resetClock()
	# because when we close the network below it doesn't actually send this signal
	# we get to call it yippee
	_peerDisconnected(ownId)
	# because erase() queue_free() and anything else was taken, this is how you
	# kill an ENet and hopefully other multiplayer peers
	network.close()

## emitted by the ENetMultiplayerPeer we have named network
func _peerConnected(peerId:int):
	print("Client: Connected to server.")
	# emitting a redundant signal I hope
	emit_signal("connected_to_server")
	
	# we store our Id for some reason
	ownId = multiplayer.get_unique_id()
	print("ownId: ",ownId)
	
	# initialising the NetworkClock and getting our "Ping"
	NetworkClock.requestPing()
	NetworkClock.setupPingTimer()

## emitted by the ENetMultiplayerPeer we have named network
func _peerDisconnected(peerId:int):
	print("Client: Disconnected from server.")
	# emitting a redundant signal I hope
	emit_signal("disconnected_from_server")

#endregion
