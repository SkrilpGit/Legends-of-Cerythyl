extends Control

var status:String = "Disconnected"
var statusLabel: Label
var pingLabel:Label


func _ready() -> void:
	statusLabel = find_child("ConnectionStatus")
	pingLabel = find_child("Ping")
	NetworkServer.connected_to_server.connect(_connected)
	NetworkServer.disconnected_from_server.connect(_disconnected)

func _physics_process(_delta: float) -> void:
	
	statusLabel.text = status
	pingLabel.text = "Ping: " + str(NetworkClock.Ping)

func _connected():
	status = "Connected"
func _disconnected():
	status = "Disconnected"
