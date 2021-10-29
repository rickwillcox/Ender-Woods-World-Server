extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var port = 1912
#var ip = "192.99.247.42"
var ip = "127.0.0.1"
var connected = false

onready var gameserver = get_node("/root/Server")

func _ready():
	ConnectToServer()
	network.connect("connection_failed", self, "_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")	
	network.connect("server_disconnected", self, "_server_disconnected")
	
func _process(delta):
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return;
	custom_multiplayer.poll();
		
func ConnectToServer():
	network.create_client(ip, port)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)



func _server_disconnected():
	connected = false
	print("Attempting to reconnect to the Authentication Server")
	while not connected:
		yield(get_tree().create_timer(5), "timeout")
		ConnectToServer()
	

func _OnConnectionFailed():	
	connected = false
	print("Failed to connect to the Game Hub server")
	
func _OnConnectionSucceeded():
	connected = true
	print("Successfully connected to Game Hub server")
#	gameserver.StartServer()

remote func ReceiveLoginToken(token):
	gameserver.expected_tokens.append(token)
	
func SendPlayerTokenToAuthDatabase(player_id, token):
	rpc_id(1, "ReceivePlayerTokenForDatabase", player_id, token)

func TestAuthUsingPlayerID(player_id, test_data):
	rpc_id(1, "TestAuthUsingPlayerID", player_id, test_data)
