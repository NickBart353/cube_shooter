class_name SpawnManager
extends Node

var player_scene: PackedScene
var name_to_add: String = ""

@onready var spawn_path: Node2D = get_tree().current_scene.get_node("%PlayerSpawn") 

func _ready() -> void:
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	
	if not OS.has_feature("dedicated_server"):
		_add_player_to_game(1)
	
func _peer_connected(pid):
	print("Peer: {0} has joined!".format([pid]))
	_add_player_to_game(pid)

func _peer_disconnected(pid):
	print("Peer: {0} has left!".format([pid]))
	var player_to_remove = spawn_path.find_child(str(pid), false, false)
	if player_to_remove:
		player_to_remove.queue_free()

func _add_player_to_game(pid: int):
	var player_to_add = player_scene.instantiate()
	player_to_add.name = str(pid)
	player_to_add.set_multiplayer_authority(pid)
	
	spawn_path.add_child(player_to_add, true)
