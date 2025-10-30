class_name Game
extends Node

@onready var MAINMENU = $CanvasLayer/MainMenu

const PLAYER: PackedScene = preload("res://scenes/component_scenes/player.tscn")
const POWERUP: PackedScene = preload("res://scenes/component_scenes/power_up.tscn")

var peer = ENetMultiplayerPeer.new()
var player_list: Array[Player] = []
var powerups: Dictionary = {}

func _ready() -> void:
	if OS.has_feature("dedicated_server"):
		_on_host_pressed()
	$PlayerSpawner.spawn_function = add_player
	$PowerUpSpawner.spawn_function = spawn_power_ups

func _process(_delta: float) -> void:
	pass

func _on_host_pressed() -> void:
	peer.create_server(25565)
	multiplayer.multiplayer_peer = peer
	
	multiplayer.peer_connected.connect(
		func(pid):
			print("Peer: {0} has joined!".format([pid]))
			$PlayerSpawner.spawn(pid)
	)
	if not OS.has_feature("dedicated_server"):
		$PlayerSpawner.spawn(multiplayer.get_unique_id())
	MAINMENU.hide()

func _on_join_pressed() -> void:
	peer.create_client("localhost", 25565)#217.154.144.91
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
		for spawn_point in $Level/PlayerSpawnPoints.get_children():
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
		player_spawn_point = $Level/PlayerSpawnPoints.get_children().pick_random()
	return player_spawn_point

func spawn_power_ups(data) -> Node:
	var powerup = POWERUP.instantiate()
	powerup.global_position = data["pos"]
	powerup.set_powerup_type(data["type"])
	return powerup

func _on_power_up_timer_timeout() -> void:
	if not multiplayer.get_unique_id() == 1: return
	if player_list.size() == 0: return
	if powerups.size() >= 4: return
	
	var spawns: Array = $Level/PowerUpSpawnPoints.get_children()
	var spawn_index: int = randi_range(0, spawns.size()-1)
	
	while powerups.get(spawn_index):
		spawn_index = randi_range(0, spawns.size()-1)
	powerups.set(spawn_index, spawns.get(spawn_index))
	
	var powerup_type = randi_range(0, 3)
	
	var data_to_send = {
		"pos": spawns.get(spawn_index).global_position,
		"type": powerup_type
	}
	
	$PowerUpSpawner.spawn(data_to_send)
	
