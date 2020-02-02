extends Node

const DEFAULT_IP = '127.0.0.1'
const DEFAULT_PORT = 31400
const MAX_PLAYERS = 3

var players = { }
var self_data = { name = '', position = Vector3(0, 10, 0) }

signal player_disconnected
signal server_disconnected

var server_started = false
var server_id = 0

func get_server_id():
	if server_id == 0:
		server_id = get_tree().get_network_unique_id()
	return server_id

func _ready():
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
	get_tree().connect('network_peer_connected', self, '_on_player_connected')

func start_server():
	self_data.name = "host"
	print("Creating server")
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT, MAX_PLAYERS)
	get_tree().set_network_peer(peer)
	control_my_player()
	players[1] = self_data.position
	server_started = true

func join_server():
	print("Joining server")
	self_data.name = "client"
	get_tree().connect('connected_to_server', self, '_connected_to_server')
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(DEFAULT_IP, DEFAULT_PORT)
	get_tree().set_network_peer(peer)
	server_started = true

func _input(event):
	if !server_started:
		if event.is_action_pressed("make_server"):
			start_server()
	
		if event.is_action_pressed("connect_server"):
			join_server()
			
func _connected_to_server():
	control_my_player();
	rpc('spawn_player', get_server_id(), self_data.position)

func _on_player_disconnected(id):
	players.erase(id)

func _on_player_connected(id):
	print( get_server_id()," player connected : it is ", id)
	if not(get_tree().is_network_server()):
		rpc_id(1, '_request_player_info',  get_server_id(), id)

remote func _request_player_info(request_from, player_id):
	assert(get_tree().is_network_server())
	rpc_id(request_from, 'spawn_player', player_id, players[player_id])

remote func spawn_player(id, spawn_point):
	players[id] = spawn_point
	var new_player = load('res://Prefabs/Player.tscn').instance()
	new_player.set_name(str(id))
	new_player.set_network_master(id)
	print(get_server_id(), " making remote player for ", id, " at ", spawn_point)
	$'/root/Game/'.add_child(new_player)

func control_my_player():
	var my_player = $'/root/Game/Player'
	my_player.set_network_master( get_server_id())
	my_player.set_name(str( get_server_id()))
	
	self_data.position = my_player.translation
	print(get_server_id(), " making self player at ", self_data.position)


func update_position(id, position):
	players[id] = position
