class_name PowerUp
extends Area2D

var type_int : int
var power_up_type: String
@onready var sprite = $Sprite2D

func _enter_tree() -> void:
	pass

func _ready() -> void:
	match type_int:
		0:
			power_up_type = "invulnerability"
			sprite.modulate = Color(0.827, 0.685, 0.226, 1.0)
		1:
			power_up_type = "infinite_ammo"
			sprite.modulate = Color(0.431, 0.839, 0.459, 1.0)
		2:
			power_up_type = "insta_kill"
			sprite.modulate = Color(0.827, 0.212, 0.227, 1.0)
		3:
			power_up_type = "rapid_fire"
			sprite.modulate = Color(0.188, 0.782, 0.866, 1.0)
	#if multiplayer.get_unique_id() == 1:
		#var powerup_type = randi_range(0,3)
		#set_powerup_type.rpc(powerup_type)

func _process(_delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if not is_multiplayer_authority(): return
	if body is Player:
		body.consume_powerup(self)
		remove_power_up.rpc()

@rpc("call_local")
func remove_power_up():
	#queue_free()
	self.visible = false

func set_powerup_type(type):
	type_int = type
