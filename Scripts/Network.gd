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

func _ready():
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
	get_tree().connect('network_peer_connected', self, '_on_player_connected')

func _input(event):
	if !server_started:
		if event.is_action_pressed("make_server"):
			self_data.name = "host"
			var my_player = $'/root/Game/Player'
			self_data.position = my_player.translation
			print("Creating server")
			players[1] = self_data
			var peer = NetworkedMultiplayerENet.new()
			peer.create_server(DEFAULT_PORT, MAX_PLAYERS)
			get_tree().set_network_peer(peer)
			server_started = true
	
		if event.is_action_pressed("connect_server"):
			print("Joining server")
			get_tree().connect('connected_to_server', self, '_connected_to_server')
			var peer = NetworkedMultiplayerENet.new()
			peer.create_client(DEFAULT_IP, DEFAULT_PORT)
			get_tree().set_network_peer(peer)
			server_started = true

func _connected_to_server():
	server_id = get_tree().get_network_unique_id()
	control_my_player();
	rpc('_send_player_info', server_id, self_data.position)

func _on_player_disconnected(id):
	players.erase(id)

func _on_player_connected(connected_player_id):
	var local_player_id = get_tree().get_network_unique_id()
# 	if not(get_tree().is_network_server()):
# 		rpc_id(1, '_request_player_info', server_id, connected_player_id)

# remote func _request_player_info(request_from, player_id):
# 	if get_tree().is_network_server():
# 		rpc_id(request_from, 'spawn_player', player_id, players[player_id])

# # A function to be used if needed. The purpose is to request all players in the current session.
# remote func _request_players(request_from_id):
# 	if get_tree().is_network_server():
# 		for peer_id in players:
# 			if( peer_id != request_from_id):
# 				rpc_id(request_from_id, '_send_player_info', peer_id, players[peer_id])

remote func spawn_player(id, spawn_point):
	players[id] = server_id
	var new_player = load('res://Prefabs/Player2.tscn').instance()
	new_player.set_position(spawn_point)
	new_player.name = str(id)
	new_player.set_network_master(id)
	print("making remote player")
	print (get_tree().get_network_unique_id())	
	print (id)
	print (new_player.get_network_master())
	$'/root/Game/'.add_child(new_player)
#	new_player.init(info.name, info.position, true)

func control_my_player():
	var my_player = $'/root/Game/Player'
	self_data.position = my_player.translation
	self_data.name = "client"
	players[server_id] = self_data

	my_player.set_network_master(server_id)
	print("making self player ",server_id, " given to ", my_player.get_network_master())
	


func update_position(id, position):
	players[id].position = position
