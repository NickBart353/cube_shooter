extends Node

var hosting = false

func _ready() -> void:
	$CanvasLayer/Control/VBoxContainer.show()
	$CanvasLayer/Control/NameContainer.hide()

func _on_host_pressed() -> void:
	hosting = true
	$CanvasLayer/Control/NameContainer.show()
	$CanvasLayer/Control/VBoxContainer.hide()

func _on_join_pressed() -> void:
	hosting = false
	$CanvasLayer/Control/NameContainer.show()
	$CanvasLayer/Control/VBoxContainer.hide()

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_accept_name_pressed() -> void:
	var name: String = ""
	if not $CanvasLayer/Control/NameContainer/LineEdit.text:
		name = str(randi())
	else:
		name = $CanvasLayer/Control/NameContainer/LineEdit.text
	NetworkHandler.name_to_add = name
	if hosting:
		NetworkHandler.start_server()
		NetworkHandler.load_game_scene()
	else:
		NetworkHandler.load_game_scene()
		NetworkHandler.start_client()
