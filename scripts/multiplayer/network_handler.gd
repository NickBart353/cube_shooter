extends Node

const GAME_SCENE = "res://scenes/main_scenes/game.tscn"
const MENU_SCENE = "res://scenes/main_scenes/main_menu.tscn"
const PLAYER: PackedScene = preload("res://scenes/component_scenes/player.tscn")
const POWERUP: PackedScene = preload("res://scenes/component_scenes/power_up.tscn")
const IP_ADDRESS: String = "localhost" # "217.154.144.91"
const PORT: int = 42069

var peer: ENetMultiplayerPeer
var player_list: Array[Player] = []
var is_hosting_game = false

func start_server() -> void:
	is_hosting_game = true
	
	peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer

func start_client() -> void:
	_setup_client_connection_signals()
	is_hosting_game = false
	
	peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer

func _setup_client_connection_signals():
	if not multiplayer.server_disconnected.is_connected(_server_disconnected):
		multiplayer.server_disconnected.connect(_server_disconnected)

func _server_disconnected():
	print("Server disconnected!")
	terminate_connection_and_load_main_menu()

func disconnect_player(id):
	peer.disconnect_peer(id)

func load_game_scene():
	get_tree().call_deferred(&"change_scene_to_packed", preload(GAME_SCENE))

func terminate_connection_and_load_main_menu():
	_load_main_menu()

func _load_main_menu():
	get_tree().call_deferred(&"change_scene_to_packed", preload(MENU_SCENE))
	_terminate_connection()
	_disconnect_client_connection_signals()

func _terminate_connection():
	multiplayer.multiplayer_peer = null

func _disconnect_client_connection_signals():
	if multiplayer.server_disconnected.has_connections():
		multiplayer.server_disconnected.disconnect(_server_disconnected)
