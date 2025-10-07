extends Node
## This script deals with synchronising a local clock to the server's clock
## it is responsible for sending pings to the server and records 
## the Round Trip Time, saved as Ping

# setting the FPS to the same value as the physics tick rate, default 60
const FPS:int = 60
const MS_PER_FRAME:float = 1000.0 / float(FPS)
const SEC_PER_FRAME:float = MS_PER_FRAME/1000.0

#Seconds between pinging the server. Cannot be too frequent because of
#bandwidth + client clock jitter, and should not be too infrequent because
# of desync
## for right now I'm co-opting the normal ping requests and also updating the
## players position with the same frequency/Timer so this value is way lower
## than it will be, this leads to the as described jitter on the ping value
const MS_PER_PING:int = 16.7 # 16.7 is equal to 1 ping per tick at 60FPS

# we instance a Timer node and use one of its cool functions the Timeout signal
# to regulate when we're sending pings to the server
var _pingTimer:Timer

var Ping:int = 0

# returns the time since the engine started in ticks
var _clientClockMS:int:
	get: return Time.get_ticks_msec()

#the current physics frame of the client
var _rawClientTick:int = 0
#estimated offset between client and server ticks
var _tickOffset:int = 0

#estimating the official game tick in real time to the server tick variable
var clientTick:int:
	get: return _rawClientTick + _tickOffset

signal requestingPing

func _physics_process(delta: float) -> void:
	_rawClientTick += 1

## very cool, initialising the ping timer, create a new timer and set its parameters
## every time the timer runs out it calls the requestPing function
func setupPingTimer():
	if _pingTimer: return
	
	_pingTimer = Timer.new()
	
	_pingTimer.wait_time = float(MS_PER_PING)/1000.0
	_pingTimer.autostart = true
	
	_pingTimer.connect("timeout", self.requestPing)
	
	# when you want to find where the timer node is exactly remember to toggle
	# to the remote view in the inspector while the client is running
	self.add_child(_pingTimer)

## simple conversion
func _msToTicks(ms:float):
	return int(ms/MS_PER_FRAME)

#region REQUESTS

## Pinging the server, emits a signal that I may be using to call other network
## functions at the same time as pinging
func requestPing():
	if not NetworkServer.isConnected:
		return
	
	#print("Requesting Ping...")
	emit_signal("requestingPing")
	
	# this is kind of important for calling rpc functions, as far as I know rn
	# whenever you want to call an rpc function, you do the rpc or rpc_id function
	# after the name of the normal function, rpc_id passes the first parameter as
	# the id of the network peer you are trying to target, 
	# the server's id is always 1.
	s_ping.rpc_id(1, _clientClockMS, _rawClientTick)

## killing the Timer object and setting all the variables to their defaults
func resetClock():
	_pingTimer.queue_free()
	#print("ping timer: ",_pingTimer)
	Ping = 0
	_rawClientTick = 0
	_tickOffset = 0

#endregion

#region RPCS

## this is the reply from the server ping that the client sent
## the _tickOffset variable is used to synchronise the local ticks to 
## the server ticks.
@rpc ("reliable") func c_pong(
	serverTick:int,
	echoClientTick:int,
	echoClientClockMS:int
):
	#Ping in Milliseconds, Round Trip Time
	Ping = _clientClockMS - echoClientClockMS
	#one-way time in ticks, for adjusting offset
	var owtInTicks:int = _msToTicks(Ping/2.0)
	
	var clientBehindTicks:int = serverTick - echoClientTick
	
	#record the differential in ticks, to apply to client tick values when
	#informing the server of actions, in order to guess the server tick on
	#which the event happened.
	_tickOffset = clientBehindTicks - owtInTicks
	
	#print("server clock: ", clientTick)
	#print("Tick Offset: ",_tickOffset)
	
	#print("Ping: ", Ping)

#endregion

#region RPC PARITY

## again cool parity function, we send our clock and current tick off
## to the server, then the server will give us a c_pong back
@rpc("any_peer","reliable")
@warning_ignore("unused_parameter")
func s_ping(echoClientClockMS:int, echoClientTick:int):pass

#endregion
