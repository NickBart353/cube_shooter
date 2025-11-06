extends Node

func _on_host_pressed() -> void:
	NetworkHandler.start_server()
	NetworkHandler.load_game_scene()

func _on_join_pressed() -> void:
	NetworkHandler.load_game_scene()
	NetworkHandler.start_client()

func _on_exit_pressed() -> void:
	get_tree().quit()
