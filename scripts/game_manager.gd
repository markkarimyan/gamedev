extends Node2D

signal ultimate_cinematic_started(player_id: int)
signal ultimate_cinematic_finished(player_id: int)

const TARGET_SCORE := 3
const ULTIMATE_CHARGE_PER_SECOND := 4.0
const ULTIMATE_CINEMATIC_SECONDS := 2.0
const COFFEE_ULTIMATE_CINEMATIC_SECONDS := 3
const CAR_ULTIMATE_SCENE := preload("res://scenes/CarUltimate.tscn")
const MAIN_ARENA_SCENE := preload("res://scenes/arenas/CampusArena.tscn")
const PLAYER_1_FACE_TEXTURE := preload("res://assets/player1_face_pixel.png")
const PLAYER_2_FACE_TEXTURE := preload("res://assets/player2_face_pixel.png")
const PORTRAIT_BACKGROUND_KEY_SHADER := preload("res://shaders/portrait_background_key.gdshader")
const PLAYER_1_ULTIMATE_POWER_UP := preload("res://assets/sfx/player1_ultimate_power_up.mp3")
const PLAYER_2_ULTIMATE_HORN := preload("res://assets/sfx/player2_ultimate_horn.mp3")
const CINEMATIC_DIM_ALPHA := 0.58
const FACE_START_SCALE := 0.05
const FACE_END_SCALE := 0.42
const FACE_START_ALPHA := 0.80
const FACE_END_ALPHA := 0.08
const PLAYER_1_ULTIMATE_POWER_UP_VOLUME_DB := -3.0
const PLAYER_2_ULTIMATE_HORN_VOLUME_DB := -1.0

var score_1 := 0
var score_2 := 0
var round_number := 1
var round_active := true
var cinematic_freeze_active := false
var cinematic_player_id := 0
var cinematic_overlay_duration := 0.0
var cinematic_overlay_elapsed := 0.0
var _frozen_physics_nodes: Array[Node] = []
var face_material: ShaderMaterial
var player_1_ultimate_power_up: AudioStreamPlayer
var player_2_ultimate_horn: AudioStreamPlayer

@onready var player_1 = %Player1
@onready var player_2 = %Player2
@onready var hud = %HUD
@onready var arena: Node2D = %Arena
@onready var cinematic_overlay: CanvasLayer = %CinematicOverlay
@onready var cinematic_dim: ColorRect = %CinematicDim
@onready var cinematic_face: Sprite2D = %CinematicFace
@onready var p1_spawn: Marker2D
@onready var p2_spawn: Marker2D
var arena_background: Sprite2D

func _ready() -> void:
	_apply_selected_level_background()
	_setup_audio()
	_setup_cinematic_overlay()
	_sync_spawn_markers()
	player_1.health_changed.connect(_on_player_health_changed)
	player_2.health_changed.connect(_on_player_health_changed)
	player_1.ultimate_charge_changed.connect(_on_player_ultimate_charge_changed)
	player_2.ultimate_charge_changed.connect(_on_player_ultimate_charge_changed)
	player_1.ultimate_activated.connect(_on_player_ultimate_activated)
	player_2.ultimate_activated.connect(_on_player_ultimate_activated)
	player_1.defeated.connect(_on_player_defeated)
	player_2.defeated.connect(_on_player_defeated)
	_start_round(false)


func _process(delta: float) -> void:
	_update_cinematic_overlay(delta)
	if not round_active or cinematic_freeze_active:
		return
	player_1.add_ultimate_charge(ULTIMATE_CHARGE_PER_SECOND * delta)
	player_2.add_ultimate_charge(ULTIMATE_CHARGE_PER_SECOND * delta)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_R:
			get_tree().reload_current_scene()
		elif event.keycode == KEY_ESCAPE:
			get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
		elif event.keycode == KEY_G and round_active and not cinematic_freeze_active:
			player_1.try_activate_ultimate()
		elif event.keycode == KEY_SHIFT and round_active and not cinematic_freeze_active:
			player_2.try_activate_ultimate()


func _start_round(should_randomize_arena := false) -> void:
	_set_match_cinematic_frozen(false)
	_clear_car_ultimates()
	_clear_round_projectiles()
	if should_randomize_arena:
		_reload_main_arena()
	_sync_spawn_markers()
	round_active = true
	hud.set_round(round_number)
	hud.set_scores(score_1, score_2, TARGET_SCORE)
	hud.clear_message()
	player_1.reset_for_round(p1_spawn.global_position)
	player_2.reset_for_round(p2_spawn.global_position)


func _reload_main_arena() -> void:
	var old_arena := arena
	arena = MAIN_ARENA_SCENE.instantiate()
	arena.name = "Arena"
	if old_arena != null and old_arena.is_inside_tree():
		old_arena.unique_name_in_owner = false
		old_arena.name = "PreviousArena"
		old_arena.queue_free()
	add_child(arena)
	arena.owner = self
	arena.unique_name_in_owner = true
	move_child(arena, 0)
	_apply_selected_level_background()


func _apply_selected_level_background() -> void:
	arena_background = arena.get_node("Background/ArenaBackground")
	var level: Dictionary = get_node("/root/GameState").get_selected_level()
	var background_texture := load(str(level["background_path"]))
	if background_texture is Texture2D:
		arena_background.texture = background_texture


func _sync_spawn_markers() -> void:
	p1_spawn = arena.get_node("Spawns/P1Spawn")
	p2_spawn = arena.get_node("Spawns/P2Spawn")


func _on_player_health_changed(player_id: int, health: int, max_health: int) -> void:
	hud.set_health(player_id, health, max_health)


func _on_player_ultimate_charge_changed(player_id: int, charge: float, max_charge: float, is_ready: bool) -> void:
	hud.set_ultimate_charge(player_id, charge, max_charge, is_ready)


func apply_player_hit(attacker_id: int, defender_id: int, damage: int, source_position: Vector2) -> bool:
	if cinematic_freeze_active:
		return false
	var attacker := _player_for_id(attacker_id)
	var defender := _player_for_id(defender_id)
	if defender == null or attacker == null or attacker == defender:
		return false
	var hit_applied := defender.take_hit(damage, source_position)
	if hit_applied:
		attacker.add_ultimate_charge_for_damage_dealt(damage)
	return hit_applied


func _player_for_id(player_id: int) -> Player:
	if player_id == 1:
		return player_1
	if player_id == 2:
		return player_2
	return null


func is_match_cinematic_frozen() -> bool:
	return cinematic_freeze_active


func start_ultimate_cinematic(player_id: int, duration := ULTIMATE_CINEMATIC_SECONDS) -> bool:
	if not round_active or cinematic_freeze_active:
		return false
	var player := _player_for_id(player_id)
	if player == null:
		return false

	cinematic_player_id = player_id
	_set_match_cinematic_frozen(true)
	if player_id == 1:
		player_1.play_coffee_ultimate_animation()
	_start_cinematic_overlay(player_id, duration)
	ultimate_cinematic_started.emit(player_id)
	get_tree().create_timer(duration).timeout.connect(_finish_ultimate_cinematic.bind(player_id))
	return true


func _finish_ultimate_cinematic(player_id: int) -> void:
	if cinematic_freeze_active and cinematic_player_id == player_id:
		_set_match_cinematic_frozen(false)
		ultimate_cinematic_finished.emit(player_id)
		if round_active and player_id == 1:
			player_1.start_coffee_overdrive()
		elif round_active and player_id == 2:
			_spawn_car_ultimate(player_2)


func _on_player_ultimate_activated(player_id: int) -> void:
	if player_id == 1:
		if start_ultimate_cinematic(player_id, COFFEE_ULTIMATE_CINEMATIC_SECONDS):
			_play_player_1_ultimate_power_up()
	else:
		if start_ultimate_cinematic(player_id):
			_play_player_2_ultimate_horn()


func _setup_audio() -> void:
	player_1_ultimate_power_up = AudioStreamPlayer.new()
	player_1_ultimate_power_up.name = "Player1UltimatePowerUp"
	player_1_ultimate_power_up.stream = PLAYER_1_ULTIMATE_POWER_UP
	player_1_ultimate_power_up.volume_db = PLAYER_1_ULTIMATE_POWER_UP_VOLUME_DB
	if player_1_ultimate_power_up.stream is AudioStreamMP3:
		player_1_ultimate_power_up.stream.loop = false
	add_child(player_1_ultimate_power_up)

	player_2_ultimate_horn = AudioStreamPlayer.new()
	player_2_ultimate_horn.name = "Player2UltimateHorn"
	player_2_ultimate_horn.stream = PLAYER_2_ULTIMATE_HORN
	player_2_ultimate_horn.volume_db = PLAYER_2_ULTIMATE_HORN_VOLUME_DB
	if player_2_ultimate_horn.stream is AudioStreamMP3:
		player_2_ultimate_horn.stream.loop = false
	add_child(player_2_ultimate_horn)


func _play_player_1_ultimate_power_up() -> void:
	player_1_ultimate_power_up.stop()
	player_1_ultimate_power_up.play()


func _play_player_2_ultimate_horn() -> void:
	player_2_ultimate_horn.stop()
	player_2_ultimate_horn.play()


func _spawn_car_ultimate(player: Player) -> void:
	var car := CAR_ULTIMATE_SCENE.instantiate()
	car.owner_id = player.player_id
	car.direction = player.facing
	car.global_position = Vector2(-170.0 if player.facing > 0 else 1130.0, player.global_position.y - 42.0)
	add_child(car)


func _clear_car_ultimates() -> void:
	for car in get_tree().get_nodes_in_group("car_ultimate"):
		if car.is_inside_tree() and car.get_parent() == self:
			car.queue_free()


func _clear_round_projectiles() -> void:
	for projectile in get_tree().get_nodes_in_group("round_projectiles"):
		if projectile.is_inside_tree() and projectile.get_parent() == self:
			projectile.queue_free()


func _set_match_cinematic_frozen(is_frozen: bool) -> void:
	if cinematic_freeze_active == is_frozen:
		return
	cinematic_freeze_active = is_frozen
	if is_frozen:
		_freeze_gameplay_nodes()
	else:
		_restore_gameplay_nodes()
		cinematic_player_id = 0
		if cinematic_overlay_elapsed >= cinematic_overlay_duration:
			_hide_cinematic_overlay()


func _setup_cinematic_overlay() -> void:
	cinematic_overlay.visible = false
	cinematic_dim.color = Color(0.0, 0.0, 0.0, 0.0)
	cinematic_face.centered = true
	cinematic_face.visible = false
	cinematic_face.modulate = Color.WHITE
	face_material = ShaderMaterial.new()
	face_material.shader = PORTRAIT_BACKGROUND_KEY_SHADER
	face_material.set_shader_parameter("max_alpha", FACE_START_ALPHA)
	cinematic_face.material = face_material


func _start_cinematic_overlay(player_id: int, duration: float) -> void:
	cinematic_overlay_duration = maxf(duration, 0.01)
	cinematic_overlay_elapsed = 0.0
	cinematic_overlay.visible = true
	cinematic_face.visible = true
	cinematic_face.texture = PLAYER_1_FACE_TEXTURE if player_id == 1 else PLAYER_2_FACE_TEXTURE
	cinematic_face.position = get_viewport_rect().size * 0.5
	cinematic_face.scale = Vector2.ONE * FACE_START_SCALE
	cinematic_face.modulate = Color.WHITE
	face_material.set_shader_parameter("max_alpha", FACE_START_ALPHA)
	cinematic_dim.color = Color(0.0, 0.0, 0.0, CINEMATIC_DIM_ALPHA)


func _update_cinematic_overlay(delta: float) -> void:
	if not cinematic_overlay.visible:
		return
	cinematic_overlay_elapsed += delta
	var progress := clampf(cinematic_overlay_elapsed / cinematic_overlay_duration, 0.0, 1.0)
	var eased_progress := 1.0 - pow(1.0 - progress, 2.0)
	cinematic_face.position = get_viewport_rect().size * 0.5
	cinematic_face.scale = Vector2.ONE * lerpf(FACE_START_SCALE, FACE_END_SCALE, eased_progress)
	face_material.set_shader_parameter("max_alpha", lerpf(FACE_START_ALPHA, FACE_END_ALPHA, eased_progress))
	cinematic_dim.color = Color(0.0, 0.0, 0.0, CINEMATIC_DIM_ALPHA * (1.0 - progress * 0.35))
	if progress >= 1.0 and not cinematic_freeze_active:
		_hide_cinematic_overlay()


func _hide_cinematic_overlay() -> void:
	cinematic_overlay.visible = false
	cinematic_face.visible = false
	cinematic_dim.color = Color(0.0, 0.0, 0.0, 0.0)


func _freeze_gameplay_nodes() -> void:
	_frozen_physics_nodes.clear()
	for node in _cinematic_freeze_nodes(self):
		if node is Node and node.is_physics_processing():
			_frozen_physics_nodes.append(node)
			node.set_physics_process(false)
	player_1.controls_enabled = false
	player_2.controls_enabled = false


func _restore_gameplay_nodes() -> void:
	for node in _frozen_physics_nodes:
		if is_instance_valid(node):
			node.set_physics_process(true)
	_frozen_physics_nodes.clear()
	if round_active:
		player_1.controls_enabled = true
		player_2.controls_enabled = true


func _cinematic_freeze_nodes(parent: Node) -> Array[Node]:
	var nodes: Array[Node] = []
	for child in parent.get_children():
		if child.is_in_group("cinematic_freeze_pauses"):
			nodes.append(child)
		nodes.append_array(_cinematic_freeze_nodes(child))
	return nodes


func _on_player_defeated(loser_id: int) -> void:
	if not round_active:
		return
	_set_match_cinematic_frozen(false)
	_clear_car_ultimates()
	round_active = false
	player_1.controls_enabled = false
	player_2.controls_enabled = false

	var winner_id := 2 if loser_id == 1 else 1
	if winner_id == 1:
		score_1 += 1
	else:
		score_2 += 1
	hud.set_scores(score_1, score_2, TARGET_SCORE)
	hud.show_message("Player %d wins the round!" % winner_id)

	if score_1 >= TARGET_SCORE or score_2 >= TARGET_SCORE:
		get_node("/root/GameState").winner_name = "Player %d" % winner_id
		await get_tree().create_timer(1.4).timeout
		get_tree().change_scene_to_file("res://scenes/WinScreen.tscn")
	else:
		round_number += 1
		await get_tree().create_timer(1.4).timeout
		_start_round(true)
