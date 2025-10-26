class_name Game
extends Node

@onready var MAINMENU = $CanvasLayer/MainMenu

const PLAYER: PackedScene = preload("res://scenes/component_scenes/player.tscn")

var peer = ENetMultiplayerPeer.new()
var player_list: Array[Player] = []

func _ready() -> void:
	$PlayerSpawner.spawn_function = add_player

func _on_host_pressed() -> void:
	peer.create_server(25565)
	multiplayer.multiplayer_peer = peer
	
	multiplayer.peer_connected.connect(
		func(pid):
			print("Peer: {0} has joined!".format([pid]))
			$PlayerSpawner.spawn(pid)
	)
	$PlayerSpawner.spawn(multiplayer.get_unique_id())
	MAINMENU.hide()

func _on_join_pressed() -> void:
	peer.create_client("localhost", 25565)
	multiplayer.multiplayer_peer = peer
	MAINMENU.hide()

func add_player(pid):
	var player_instance = PLAYER.instantiate()
	player_instance.name = "{0}".format([pid])
	player_instance.global_position = get_random_spawnpoint().global_position
	player_list.append(player_instance)
	return player_instance

func get_random_spawnpoint():
	var max_distance
	var nearest_player_distance
	var nearest_player_distance_dict: Dictionary = {}
	var player_spawn_point
	if player_list:
		for spawn_point in $Level.get_children():
			nearest_player_distance = INF
			for player in player_list:
				var new_distance = spawn_point.global_position.distance_to(player.global_position)
				if new_distance < nearest_player_distance:
					nearest_player_distance = new_distance
			nearest_player_distance_dict[spawn_point] = nearest_player_distance
			
		max_distance = nearest_player_distance_dict.values().max()
		for spawnpoint in nearest_player_distance_dict:
			if nearest_player_distance_dict.get(spawnpoint) == max_distance:
				player_spawn_point = spawnpoint
				break
	else:
		player_spawn_point = $Level.get_children().pick_random()
	return player_spawn_point
