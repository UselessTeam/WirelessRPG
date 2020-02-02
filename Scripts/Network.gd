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

func start_server(name):
	self_data.name = name
	print("Creating server")
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT, MAX_PLAYERS)
	get_tree().set_network_peer(peer)
	server_started = true

func join_server(name, ip):
	if ip == "":
		ip = DEFAULT_IP
	print("Joining server")
	self_data.name = "client"
	get_tree().connect('connected_to_server', self, '_connected_to_server')
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(peer)
	server_started = true

func _connected_to_server():
	control_my_player();
	rpc('spawn_player', get_server_id(), self_data.position)

func _on_player_disconnected(id):
	players.erase(id)

func _on_player_connected(id):
	print( get_server_id()," player connected : it is ", id)
	if not(get_tree().is_network_server()):
		rpc_id(1, 'make_spawn_player',  get_server_id(), id)

func _game_started():
	print("Game started")
	control_my_player()
	if(get_tree().is_network_server()):
		Network.players[1] = self_data.position

remote func make_spawn_player(request_from, id):
	print( get_server_id()," make spawn request from ", request_from, " to make ", id)
	rpc_id(request_from, 'spawn_player', id, players[id])

remote func spawn_player(id, spawn_point):
	players[id] = spawn_point
	var new_player = load('res://Prefabs/Player.tscn').instance()
	new_player.set_name(str(id))
	new_player.set_network_master(id)
	print(get_server_id(), " making remote player for ", id, " at ", spawn_point)
	$'/root/Game/'.add_child(new_player)

func control_my_player():
	var my_player = $'/root/Game/Player'
	my_player.set_network_master(get_server_id())
	my_player.set_name(str( get_server_id()))
	
	self_data.position = my_player.translation
	print(get_server_id(), " making self player at ", self_data.position)

func update_position(id, position):
	players[id] = position
