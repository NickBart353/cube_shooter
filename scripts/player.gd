class_name Player
extends CharacterBody2D

@onready var game: Game = get_parent()

const SPEED = 3000.0
const JUMP_VELOCITY = -200.0
const acceleration = 400
const MAX_HEALTH = 100
const BULLET = preload("res://scenes/component_scenes/bullet.tscn")

var health = 100

func _enter_tree() -> void:
	set_multiplayer_authority(int(str(name)))

func _ready() -> void:
	if not is_multiplayer_authority():
		$Sprite2D.modulate = Color.RED

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	if not is_on_floor():
		velocity += get_gravity()/2 * delta
		
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED * delta
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if Input.is_action_just_pressed("shoot"):
		shoot.rpc()
	
	$GunContainer.look_at(get_global_mouse_position())
	$GunContainer/GunSprite.flip_v = get_global_mouse_position().x < global_position.x

	move_and_slide()

@rpc("call_local")
func shoot():
	var bullet = BULLET.instantiate()
	get_parent().add_child(bullet)
	bullet.transform = $GunContainer/GunSprite/Muzzle.global_transform

func take_damage(amount):
	health -= amount
	
	if health <= 0:
		health = MAX_HEALTH
		global_position = game.get_random_spawnpoint().global_position
