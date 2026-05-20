extends CharacterBody2D
class_name Player

signal health_changed(player_id: int, health: int, max_health: int)
signal defeated(player_id: int)
signal ultimate_charge_changed(player_id: int, charge: float, max_charge: float, is_ready: bool)
signal ultimate_activated(player_id: int)

const MAX_HEALTH := 100
const MAX_ULTIMATE_CHARGE := 100.0
const ULTIMATE_CHARGE_PER_DAMAGE_DEALT := 1.0
const ULTIMATE_CHARGE_PER_DAMAGE_TAKEN := 0.7
const SPEED := 230.0
const JUMP_VELOCITY := -430.0
const GRAVITY := 1200.0
const SHOT_RECOIL_TIME := 0.12
const INVULNERABLE_TIME := 0.45
const KNOCKBACK_CONTROL_LOCK_TIME := 0.18
const KNOCKBACK_FORCE := Vector2(330.0, -170.0)
const COFFEE_OVERDRIVE_SECONDS := 7
const COFFEE_CRASH_SECONDS := 0.85
const COFFEE_SPEED_MULTIPLIER := 1.45
const COFFEE_JUMP_MULTIPLIER := 1.18
const COFFEE_SHOOT_COOLDOWN_MULTIPLIER := 0.58
const COFFEE_CRASH_SPEED_MULTIPLIER := 0.62
const DAMAGE_BOOST_SECONDS := 7.0
const DAMAGE_BOOST_MULTIPLIER := 1.55
const BULLET_SCENE := preload("res://scenes/Bullet.tscn")
const PISTOL_SHOT_SOUND := preload("res://assets/sfx/pistol_shot.mp3")
const COFFEE_DRINK_SOUND := preload("res://assets/sfx/coffee_drink.mp3")
const COFFEE_ULTIMATE_TEXTURE := preload("res://assets/ultimates/rebull.png")
const COFFEE_ULTIMATE_WALK_TEXTURE := preload("res://assets/ultimates/ult_walk.png")
const SPRITE_BASE_POSITION := Vector2(0, -33)
const MUZZLE_Y := -51.0
const DEFAULT_WALK_FRAMES := 4
const COFFEE_ULTIMATE_FRAMES := 8
const COFFEE_ULTIMATE_WALK_FRAMES := 4
const COFFEE_ULTIMATE_POSE_SECONDS := 2
const DEFAULT_SPRITE_SCALE := Vector2(0.20, 0.20)
const COFFEE_ULTIMATE_SPRITE_SCALE := Vector2(0.35, 0.35)
const COFFEE_ULTIMATE_WALK_SPRITE_SCALE := Vector2(0.20, 0.20)
const PISTOL_SHOT_VOLUME_DB := -2.0
const COFFEE_DRINK_VOLUME_DB := 10.0
const COFFEE_DRINK_DELAY_SECONDS := 0.35

@export var player_id := 1
@export var body_color := Color("3aa7ff")
@export var sprite_texture: Texture2D
@export var start_facing := 1

var health := MAX_HEALTH
var ultimate_charge := 0.0
var ultimate_ready := false
var facing := 1
var controls_enabled := true
var max_jumps := 2
var jumps_left := 2
var shoot_cooldown_left := 0.0
var shot_recoil_left := 0.0
var invulnerable_left := 0.0
var knockback_left := 0.0
var walk_frame_time := 0.0
var jump_boost_left := 0.0
var coffee_overdrive_left := 0.0
var coffee_crash_left := 0.0
var damage_boost_left := 0.0
var coffee_ultimate_pose_left := 0.0
var default_sprite_texture: Texture2D
var weapon_name := ""
var weapon_damage := 12
var weapon_cooldown := 0.42
var weapon_bullet_speed := 560.0
var weapon_bullet_color := Color(1.0, 0.84, 0.22, 1.0)
var previous_jump_pressed := false
var previous_shoot_pressed := false
var pistol_shot_player: AudioStreamPlayer
var coffee_drink_player: AudioStreamPlayer

@onready var full_sprite: Sprite2D = %FullSprite
@onready var muzzle: Marker2D = %Muzzle
@onready var muzzle_flash: Polygon2D = %MuzzleFlash
@onready var muzzle_flash_core: Polygon2D = %MuzzleFlashCore
@onready var muzzle_spark: Polygon2D = %MuzzleSpark
@onready var start_position := global_position

func _ready() -> void:
	add_to_group("cinematic_freeze_pauses")
	_setup_audio()
	facing = start_facing
	default_sprite_texture = sprite_texture
	if sprite_texture != null:
		full_sprite.texture = sprite_texture
	full_sprite.hframes = DEFAULT_WALK_FRAMES
	full_sprite.scale = DEFAULT_SPRITE_SCALE
	full_sprite.frame = 0
	_apply_starting_weapon()
	_update_facing()
	health_changed.emit(player_id, health, MAX_HEALTH)


func _physics_process(delta: float) -> void:
	_tick_timers(delta)
	if is_on_floor():
		jumps_left = max_jumps
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	var direction := _movement_direction()
	if controls_enabled and knockback_left <= 0.0:
		velocity.x = direction * current_movement_speed()
		if direction != 0:
			facing = int(sign(direction))
			_update_facing()
		if _jump_just_pressed() and jumps_left > 0:
			velocity.y = current_jump_velocity()
			jumps_left -= 1
		if _shoot_just_pressed():
			_shoot()
	else:
		velocity.x = move_toward(velocity.x, 0.0, current_movement_speed() * delta * 4.0)

	move_and_slide()
	_animate_sprite(delta, direction)
	previous_jump_pressed = _jump_pressed()
	previous_shoot_pressed = _shoot_pressed()


func _process(delta: float) -> void:
	if coffee_ultimate_pose_left > 0.0:
		coffee_ultimate_pose_left -= delta
		_animate_coffee_ultimate(delta)
		if coffee_ultimate_pose_left <= 0.0:
			if not is_coffee_overdrive_active():
				_restore_default_sprite_texture()


func reset_for_round(spawn_position: Vector2) -> void:
	global_position = spawn_position
	start_position = spawn_position
	velocity = Vector2.ZERO
	health = MAX_HEALTH
	controls_enabled = true
	facing = start_facing
	_apply_starting_weapon()
	_update_facing()
	max_jumps = 2
	jumps_left = max_jumps
	shoot_cooldown_left = 0.0
	shot_recoil_left = 0.0
	invulnerable_left = 0.0
	knockback_left = 0.0
	walk_frame_time = 0.0
	jump_boost_left = 0.0
	coffee_overdrive_left = 0.0
	coffee_crash_left = 0.0
	coffee_ultimate_pose_left = 0.0
	damage_boost_left = 0.0
	_set_muzzle_fire_visible(false)
	_restore_default_sprite_texture()
	full_sprite.position = SPRITE_BASE_POSITION
	full_sprite.rotation = 0.0
	full_sprite.frame = 0
	previous_shoot_pressed = false
	health_changed.emit(player_id, health, MAX_HEALTH)
	reset_ultimate_charge()


func reset_ultimate_charge() -> void:
	ultimate_charge = 0.0
	ultimate_ready = false
	ultimate_charge_changed.emit(player_id, ultimate_charge, MAX_ULTIMATE_CHARGE, ultimate_ready)


func add_ultimate_charge(amount: float) -> void:
	if amount <= 0.0 or ultimate_ready:
		return
	ultimate_charge = minf(ultimate_charge + amount, MAX_ULTIMATE_CHARGE)
	ultimate_ready = ultimate_charge >= MAX_ULTIMATE_CHARGE
	ultimate_charge_changed.emit(player_id, ultimate_charge, MAX_ULTIMATE_CHARGE, ultimate_ready)


func try_activate_ultimate() -> bool:
	if not ultimate_ready:
		return false
	reset_ultimate_charge()
	ultimate_activated.emit(player_id)
	return true


func start_coffee_overdrive() -> void:
	coffee_ultimate_pose_left = 0.0
	coffee_overdrive_left = COFFEE_OVERDRIVE_SECONDS
	coffee_crash_left = 0.0
	_set_sprite_texture(COFFEE_ULTIMATE_WALK_TEXTURE, COFFEE_ULTIMATE_WALK_FRAMES)
	full_sprite.scale = COFFEE_ULTIMATE_WALK_SPRITE_SCALE
	full_sprite.frame = 0


func is_coffee_overdrive_active() -> bool:
	return coffee_overdrive_left > 0.0


func play_coffee_ultimate_animation() -> void:
	if player_id != 1:
		return
	_play_coffee_drink_after_delay()
	coffee_ultimate_pose_left = COFFEE_ULTIMATE_POSE_SECONDS
	_set_sprite_texture(COFFEE_ULTIMATE_TEXTURE, COFFEE_ULTIMATE_FRAMES)
	full_sprite.scale = COFFEE_ULTIMATE_SPRITE_SCALE
	full_sprite.frame = 0
	full_sprite.position = SPRITE_BASE_POSITION
	full_sprite.rotation = 0.0
	_animate_coffee_ultimate(0.0)


func is_coffee_crashing() -> bool:
	return coffee_crash_left > 0.0


func has_damage_boost() -> bool:
	return damage_boost_left > 0.0


func current_movement_speed() -> float:
	if is_coffee_overdrive_active():
		return SPEED * COFFEE_SPEED_MULTIPLIER
	if is_coffee_crashing():
		return SPEED * COFFEE_CRASH_SPEED_MULTIPLIER
	return SPEED


func current_jump_velocity() -> float:
	if is_coffee_overdrive_active():
		return JUMP_VELOCITY * COFFEE_JUMP_MULTIPLIER
	return JUMP_VELOCITY


func current_weapon_cooldown() -> float:
	if is_coffee_overdrive_active():
		return weapon_cooldown * COFFEE_SHOOT_COOLDOWN_MULTIPLIER
	return weapon_cooldown


func current_weapon_damage() -> int:
	if has_damage_boost():
		return roundi(float(weapon_damage) * DAMAGE_BOOST_MULTIPLIER)
	return weapon_damage


func add_ultimate_charge_for_damage_dealt(damage: int) -> void:
	add_ultimate_charge(float(damage) * ULTIMATE_CHARGE_PER_DAMAGE_DEALT)


func add_ultimate_charge_for_damage_taken(damage: int) -> void:
	add_ultimate_charge(float(damage) * ULTIMATE_CHARGE_PER_DAMAGE_TAKEN)


func take_hit(damage: int, source_position: Vector2) -> bool:
	if invulnerable_left > 0.0 or health <= 0:
		return false

	health = maxi(health - damage, 0)
	add_ultimate_charge_for_damage_taken(damage)
	invulnerable_left = INVULNERABLE_TIME
	var knockback_direction := signf(global_position.x - source_position.x)
	if knockback_direction == 0.0:
		knockback_direction = 1.0
	velocity = Vector2(KNOCKBACK_FORCE.x * knockback_direction, KNOCKBACK_FORCE.y)
	knockback_left = KNOCKBACK_CONTROL_LOCK_TIME
	health_changed.emit(player_id, health, MAX_HEALTH)

	if health <= 0:
		controls_enabled = false
		defeated.emit(player_id)
	return true


func _tick_timers(delta: float) -> void:
	if shoot_cooldown_left > 0.0:
		shoot_cooldown_left -= delta
	if jump_boost_left > 0.0:
		jump_boost_left -= delta
		if jump_boost_left <= 0.0:
			max_jumps = 2
	if coffee_overdrive_left > 0.0:
		coffee_overdrive_left -= delta
		if coffee_overdrive_left <= 0.0:
			coffee_crash_left = COFFEE_CRASH_SECONDS
			_restore_default_sprite_texture()
	if coffee_crash_left > 0.0:
		coffee_crash_left -= delta
	if damage_boost_left > 0.0:
		damage_boost_left -= delta
	if shot_recoil_left > 0.0:
		shot_recoil_left -= delta
		if shot_recoil_left <= 0.0:
			_set_muzzle_fire_visible(false)
		else:
			_animate_muzzle_fire()
	if invulnerable_left > 0.0:
		invulnerable_left -= delta
		full_sprite.modulate = Color(1.0, 1.0, 1.0, 0.45 if int(Time.get_ticks_msec() / 80) % 2 == 0 else 1.0)
	else:
		full_sprite.modulate = Color.WHITE
	if knockback_left > 0.0:
		knockback_left -= delta


func _shoot() -> void:
	if shoot_cooldown_left > 0.0:
		return
	shoot_cooldown_left = current_weapon_cooldown()
	var bullet := BULLET_SCENE.instantiate()
	bullet.direction = facing
	bullet.owner_id = player_id
	bullet.damage = current_weapon_damage()
	bullet.speed = weapon_bullet_speed
	bullet.bullet_color = weapon_bullet_color
	bullet.global_position = muzzle.global_position
	get_parent().add_child(bullet)
	shot_recoil_left = SHOT_RECOIL_TIME
	_set_muzzle_fire_visible(true)
	_animate_muzzle_fire()
	_play_pistol_shot()


func _setup_audio() -> void:
	pistol_shot_player = AudioStreamPlayer.new()
	pistol_shot_player.name = "PistolShotPlayer"
	pistol_shot_player.stream = PISTOL_SHOT_SOUND
	pistol_shot_player.volume_db = PISTOL_SHOT_VOLUME_DB
	if pistol_shot_player.stream is AudioStreamMP3:
		pistol_shot_player.stream.loop = false
	add_child(pistol_shot_player)

	coffee_drink_player = AudioStreamPlayer.new()
	coffee_drink_player.name = "CoffeeDrinkPlayer"
	coffee_drink_player.stream = COFFEE_DRINK_SOUND
	coffee_drink_player.volume_db = COFFEE_DRINK_VOLUME_DB
	if coffee_drink_player.stream is AudioStreamMP3:
		coffee_drink_player.stream.loop = false
	add_child(coffee_drink_player)


func _play_pistol_shot() -> void:
	pistol_shot_player.stop()
	pistol_shot_player.play()


func _play_coffee_drink() -> void:
	coffee_drink_player.stop()
	coffee_drink_player.play()


func _play_coffee_drink_after_delay() -> void:
	get_tree().create_timer(COFFEE_DRINK_DELAY_SECONDS).timeout.connect(_play_coffee_drink)


func _update_facing() -> void:
	full_sprite.flip_h = facing != start_facing
	muzzle.position.x = 42.0 * facing
	muzzle.position.y = MUZZLE_Y
	muzzle_flash.position.x = 50.0 * facing
	muzzle_flash.position.y = MUZZLE_Y
	muzzle_flash.scale.x = facing
	muzzle_flash_core.position = muzzle_flash.position
	muzzle_flash_core.scale.x = facing
	muzzle_spark.position = muzzle_flash.position
	muzzle_spark.scale.x = facing


func _animate_sprite(delta: float, direction: float) -> void:
	var base_position := SPRITE_BASE_POSITION
	if coffee_ultimate_pose_left > 0.0:
		full_sprite.position = base_position
		full_sprite.rotation = 0.0
	elif is_coffee_overdrive_active():
		if abs(direction) > 0.0 and is_on_floor():
			walk_frame_time += delta
			full_sprite.frame = int(walk_frame_time * 12.0) % COFFEE_ULTIMATE_WALK_FRAMES
			full_sprite.position = base_position
			full_sprite.rotation = 0.0
		elif not is_on_floor():
			full_sprite.frame = 1
			full_sprite.position = base_position + Vector2(0, -2)
			full_sprite.rotation = deg_to_rad(-3.0 * facing)
		else:
			walk_frame_time = 0.0
			full_sprite.frame = 0
			full_sprite.position = full_sprite.position.lerp(base_position, 12.0 * delta)
			full_sprite.rotation = lerp(full_sprite.rotation, 0.0, 12.0 * delta)
	elif controls_enabled and abs(direction) > 0.0 and is_on_floor():
		walk_frame_time += delta
		full_sprite.frame = int(walk_frame_time * 10.0) % DEFAULT_WALK_FRAMES
		full_sprite.position = base_position
		full_sprite.rotation = 0.0
	elif not is_on_floor():
		full_sprite.frame = 1
		full_sprite.position = base_position + Vector2(0, -2)
		full_sprite.rotation = deg_to_rad(-3.0 * facing)
	else:
		walk_frame_time = 0.0
		full_sprite.frame = 0
		full_sprite.position = full_sprite.position.lerp(base_position, 12.0 * delta)
		full_sprite.rotation = lerp(full_sprite.rotation, 0.0, 12.0 * delta)

	if shot_recoil_left > 0.0:
		var recoil := shot_recoil_left / SHOT_RECOIL_TIME
		full_sprite.position.x -= facing * 6.0 * recoil
		full_sprite.rotation -= deg_to_rad(facing * 5.0 * recoil)


func _animate_coffee_ultimate(_delta: float) -> void:
	var progress := 1.0 - maxf(coffee_ultimate_pose_left, 0.0) / COFFEE_ULTIMATE_POSE_SECONDS
	full_sprite.frame = mini(int(progress * COFFEE_ULTIMATE_FRAMES), COFFEE_ULTIMATE_FRAMES - 1)
	full_sprite.position = SPRITE_BASE_POSITION
	full_sprite.rotation = 0.0


func _set_sprite_texture(texture: Texture2D, frame_count: int) -> void:
	if full_sprite.texture == texture and full_sprite.hframes == frame_count:
		return
	full_sprite.texture = texture
	full_sprite.hframes = frame_count
	full_sprite.frame = mini(full_sprite.frame, frame_count - 1)


func _restore_default_sprite_texture() -> void:
	if default_sprite_texture == null:
		return
	_set_sprite_texture(default_sprite_texture, DEFAULT_WALK_FRAMES)
	full_sprite.scale = DEFAULT_SPRITE_SCALE


func _set_muzzle_fire_visible(is_visible: bool) -> void:
	muzzle_flash.visible = is_visible
	muzzle_flash_core.visible = is_visible
	muzzle_spark.visible = is_visible


func _animate_muzzle_fire() -> void:
	var recoil := shot_recoil_left / SHOT_RECOIL_TIME
	var fire_scale := 0.45 + recoil * 0.75
	muzzle_flash.scale = Vector2(facing * fire_scale, fire_scale)
	muzzle_flash_core.scale = Vector2(facing * (0.7 + recoil * 0.5), 0.7 + recoil * 0.5)
	muzzle_spark.scale = Vector2(facing * (0.65 + recoil), 0.65 + recoil)
	muzzle_flash.modulate.a = recoil
	muzzle_flash_core.modulate.a = recoil
	muzzle_spark.modulate.a = recoil * 0.85


func collect_pickup(pickup_type: String) -> void:
	match pickup_type:
		"rapid":
			weapon_cooldown = maxf(weapon_cooldown * 0.55, 0.16)
			weapon_bullet_color = Color(1.0, 0.9, 0.15, 1.0)
		"jump_boost":
			max_jumps = 3
			jumps_left = max_jumps
			jump_boost_left = 10.0
		"medkit":
			health = mini(health + 25, MAX_HEALTH)
			health_changed.emit(player_id, health, MAX_HEALTH)
		"damage_boost":
			damage_boost_left = DAMAGE_BOOST_SECONDS


func _apply_starting_weapon() -> void:
	if player_id == 1:
		_apply_weapon("Lab-Partner Blaster", 11, 0.30, 670.0, Color(0.2, 0.62, 1.0, 1.0))
	else:
		_apply_weapon("Dorm-Room Clanker", 15, 0.44, 600.0, Color(1.0, 0.26, 0.18, 1.0))


func _apply_weapon(new_name: String, damage: int, cooldown: float, bullet_speed: float, color: Color) -> void:
	weapon_name = new_name
	weapon_damage = damage
	weapon_cooldown = cooldown
	weapon_bullet_speed = bullet_speed
	weapon_bullet_color = color


func _movement_direction() -> float:
	if not controls_enabled:
		return 0.0
	var left := Input.is_key_pressed(KEY_A) if player_id == 1 else Input.is_key_pressed(KEY_LEFT)
	var right := Input.is_key_pressed(KEY_D) if player_id == 1 else Input.is_key_pressed(KEY_RIGHT)
	return float(int(right) - int(left))


func _jump_pressed() -> bool:
	return Input.is_key_pressed(KEY_W) if player_id == 1 else Input.is_key_pressed(KEY_UP)


func _shoot_pressed() -> bool:
	if player_id == 1:
		return Input.is_key_pressed(KEY_F)
	return Input.is_key_pressed(KEY_CTRL) or Input.is_key_pressed(KEY_KP_0)


func _jump_just_pressed() -> bool:
	return _jump_pressed() and not previous_jump_pressed


func _shoot_just_pressed() -> bool:
	return _shoot_pressed() and not previous_shoot_pressed
