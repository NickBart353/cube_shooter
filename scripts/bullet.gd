extends Area2D

var speed = 250
var start_position
var shooter_pid

func _ready() -> void:
	start_position = global_position

func _physics_process(delta: float) -> void:
	position += transform.x * speed * delta
	if global_position.distance_to(start_position) > 2000:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if is_multiplayer_authority():
		if body is Player:
			body.take_damage.rpc_id(body.get_multiplayer_authority(), 25, shooter_pid)
	queue_free()
