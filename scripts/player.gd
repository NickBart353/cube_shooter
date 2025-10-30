class_name Player
extends CharacterBody2D

@onready var game: Game = get_parent()

const SPEED = 3000.0
const JUMP_VELOCITY = -200.0
const acceleration = 400
const MAX_HEALTH = 100
const BULLET = preload("res://scenes/component_scenes/bullet.tscn")
const MAX_AMMO = 5

var ammo
var health = 100
var current_powerup

func _enter_tree() -> void:
	set_multiplayer_authority(int(str(name)))

func _ready() -> void:
	if not is_multiplayer_authority():
		$Sprite2D.modulate = Color.RED
	ammo = MAX_AMMO

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
	
	if Input.is_action_pressed("shoot") and ammo > 0 and $FireRateTimer.is_stopped():
		shoot.rpc(multiplayer.get_unique_id())
		ammo -= 1
		$FireRateTimer.start()

	if ammo <= 0 and $ReloadTimer.is_stopped():
		$ReloadTimer.start()
		
	$GunContainer.look_at(get_global_mouse_position())
	$GunContainer/GunSprite.flip_v = get_global_mouse_position().x < global_position.x

	move_and_slide()

@rpc("call_local")
func shoot(shooter_pid):
	var bullet = BULLET.instantiate()
	bullet.set_multiplayer_authority(shooter_pid)
	get_parent().add_child(bullet, true)
	bullet.transform = $GunContainer/GunSprite/Muzzle.global_transform

@rpc("any_peer")
func take_damage(amount):
	health -= amount
	if health <= 0:
		health = MAX_HEALTH
		global_position = game.get_random_spawnpoint().global_position

func _on_timer_timeout() -> void:
	ammo = MAX_AMMO

func _on_fire_rate_timer_timeout() -> void:
	pass

func consume_powerup(powerup):
	if not $BuffTimer.is_stopped(): return
	current_powerup = powerup
	$BuffTimer.start()
	match current_powerup.power_up_type:
		"invulnerability":
			health = INF
		"infinite_ammo":
			ammo = INF
		"insta_kill":
			pass
		"rapid_fire":
			pass

func _on_buff_timer_timeout() -> void:
	if current_powerup: return 
	reset_powerup()
	
func reset_powerup():
	match current_powerup.power_up_type:
		"invulnerability":
			health = MAX_HEALTH
		"infinite_ammo":
			ammo = MAX_AMMO
		"insta_kill":
			pass
		"rapid_fire":
			pass
	current_powerup = null
