extends Area2D

var speed = 250
var start_position

func _ready() -> void:
	start_position = global_position

func _physics_process(delta: float) -> void:
	position += transform.x * speed * delta
	if global_position.distance_to(start_position) > 2000:
		remove_bullet.rpc_id(1)

func _on_body_entered(body: Node2D) -> void:
	if not is_multiplayer_authority(): return
	if body is Player:
		body.take_damage.rpc_id(body.get_multiplayer_authority(), 25)
	remove_bullet.rpc()

@rpc("call_local")
func remove_bullet():
	queue_free()
