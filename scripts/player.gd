class_name Player
extends CharacterBody2D

@export var speed = 70.0 
@export var acceleration = 200.0 
@export var friction = 100.0

@onready var game: Game = get_parent().get_parent()

const SPEED = 50.0
const JUMP_VELOCITY = -200.0
const MAX_HEALTH = 100
const BULLET = preload("res://scenes/component_scenes/bullet.tscn")
const MAX_AMMO = 15

var ammo
var health = 100
var current_powerup
var direction = Vector2.ZERO
var user_name: String

func _enter_tree() -> void:
	set_multiplayer_authority(int(str(name)))

func _ready() -> void:
	if not is_multiplayer_authority():
		$Sprite2D.modulate = Color.RED
		$Camera2D.enabled = false
		$HUD/Name.text = user_name
	ammo = MAX_AMMO

func _physics_process(delta: float) -> void:
	if not get_multiplayer_authority(): return
	if not is_multiplayer_authority(): return
	
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	
	update_healthbar.rpc(health)
	update_ammo()
	
	if direction.length() > 0:
		velocity = velocity.move_toward(direction * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	if Input.is_action_pressed("shoot") and ammo > 0 and $FireRateTimer.is_stopped() and $ReloadTimer.is_stopped():
		shoot.rpc(multiplayer.get_unique_id())
		ammo -= 1
		$FireRateTimer.start()
	
	if (ammo <= 0 or (Input.is_action_just_pressed("reload") and not ammo == MAX_AMMO)) and $ReloadTimer.is_stopped():
		$ReloadTimer.start()
	
	if not $ReloadTimer.is_stopped():
		$HUD/AmmoContainer/ReloadProgressBar.value = $ReloadTimer.time_left * 100
	
	$GunContainer.look_at(get_global_mouse_position())
	$GunContainer/GunSprite.flip_v = get_global_mouse_position().x < global_position.x

	move_and_slide()

@rpc("call_local")
func shoot(shooter_pid):
	var bullet = BULLET.instantiate()
	bullet.set_multiplayer_authority(shooter_pid)
	bullet.transform = $GunContainer/GunSprite/Muzzle.global_transform
	game.add_child(bullet, true)

@rpc("any_peer")
func take_damage(amount):
	health -= amount
	if health <= 0:
		_reset_player()
		health = MAX_HEALTH
		global_position = game.get_random_spawnpoint().global_position

func _on_timer_timeout() -> void:
	ammo = MAX_AMMO
	$HUD/AmmoContainer/ReloadProgressBar.value = 0

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
	reset_powerup()

func reset_powerup():
	if not current_powerup: return 
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
	remove_power_up.rpc_id(1)

@rpc("call_local")
func remove_power_up():
	current_powerup.queue_free()

@rpc("call_local")
func update_healthbar(synced_health):
	$ProgressBar/HealthBar.value = synced_health

func update_ammo():
	$HUD/AmmoContainer/AmmoCounter.text = str(ammo)

func _reset_player():
	reset_powerup()
	health = MAX_HEALTH
	_on_timer_timeout()
	reset_timers()

func reset_timers():
	$ReloadTimer.stop()
	$FireRateTimer.stop()
	$BuffTimer.stop()

func _on_main_menu_pressed() -> void:
	NetworkHandler.terminate_connection_and_load_main_menu()
