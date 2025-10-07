extends Control

var IP_Address:String = "localhost"
var port:int = 1032

@export var gameScene:PackedScene

var connected:bool = false

var addressEdit: LineEdit
var portEdit: LineEdit
var connectButton: Button

func _ready() -> void:
	NetworkServer.connected_to_server.connect(_on_connection)
	addressEdit = $VBoxContainer/IPAddress/LineEdit
	portEdit = $VBoxContainer/Port/LineEdit
	connectButton = $VBoxContainer/Connect

func _on_connect_pressed() -> void:
	
	if connected:
		NetworkServer.disconnectFromServer()
		connectButton.text = "Connect"
		connected = false
		$VBoxContainer/Play.disabled = true
		return
	
	IP_Address = addressEdit.text
	port = int(portEdit.text)
	print("ServerBrowser: Port: ",port, " IP: ", IP_Address)
	NetworkServer.port = port
	NetworkServer.connectToIP(IP_Address)
	

func _on_connection():
	print("ServerBrowser: CONNECTED!")
	$VBoxContainer/Play.disabled = false
	connected = true
	connectButton.text = "Disconnect"
	pass


func _on_play_pressed() -> void:
	print("ServerBrowser: loading game...")
	if gameScene:
		get_tree().change_scene_to_packed(gameScene)
	pass # Replace with function body.
