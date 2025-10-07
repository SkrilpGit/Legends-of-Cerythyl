extends Node

## Server side clock stuff is really simple, all we have to do is increment our
## tick

var serverTick:int = 0

func _physics_process(delta: float) -> void:
	serverTick += 1

#region RPCS

## after recieving a ping we send back the info to the client that requested
## plus the serverTick
@rpc("any_peer", "reliable")
func s_ping(echoClientMS:int, echoClientTick:int):
	var requestingClientId:int = multiplayer.get_remote_sender_id()
	
	#print(
		#"Returning Ping to client ", requestingClientId,
		#" on tick ", serverTick
	#)
	
	#print("server clock: ", serverTick)
	
	c_pong.rpc_id(
		requestingClientId,
		serverTick,
		echoClientTick,
		echoClientMS
	)

#endregion

#region RPC PARITY

@rpc("reliable") func c_pong(echoClientTick:int, echoClientMS:int): pass

#endregion
