extends Node2D

const TARGET_SCORE := 3
const ULTIMATE_CHARGE_PER_SECOND := 4.0

var score_1 := 0
var score_2 := 0
var round_number := 1
var round_active := true

@onready var player_1 = %Player1
@onready var player_2 = %Player2
@onready var hud = %HUD
@onready var p1_spawn: Marker2D = %P1Spawn
@onready var p2_spawn: Marker2D = %P2Spawn

func _ready() -> void:
	player_1.health_changed.connect(_on_player_health_changed)
	player_2.health_changed.connect(_on_player_health_changed)
	player_1.ultimate_charge_changed.connect(_on_player_ultimate_charge_changed)
	player_2.ultimate_charge_changed.connect(_on_player_ultimate_charge_changed)
	player_1.defeated.connect(_on_player_defeated)
	player_2.defeated.connect(_on_player_defeated)
	_start_round()


func _process(delta: float) -> void:
	if not round_active:
		return
	player_1.add_ultimate_charge(ULTIMATE_CHARGE_PER_SECOND * delta)
	player_2.add_ultimate_charge(ULTIMATE_CHARGE_PER_SECOND * delta)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_R:
			get_tree().reload_current_scene()
		elif event.keycode == KEY_ESCAPE:
			get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
		elif event.keycode == KEY_G and round_active:
			player_1.try_activate_ultimate()
		elif event.keycode == KEY_SHIFT and round_active:
			player_2.try_activate_ultimate()


func _start_round() -> void:
	round_active = true
	hud.set_round(round_number)
	hud.set_scores(score_1, score_2, TARGET_SCORE)
	hud.clear_message()
	player_1.reset_for_round(p1_spawn.global_position)
	player_2.reset_for_round(p2_spawn.global_position)


func _on_player_health_changed(player_id: int, health: int, max_health: int) -> void:
	hud.set_health(player_id, health, max_health)


func _on_player_ultimate_charge_changed(player_id: int, charge: float, max_charge: float, is_ready: bool) -> void:
	hud.set_ultimate_charge(player_id, charge, max_charge, is_ready)


func apply_player_hit(attacker_id: int, defender_id: int, damage: int, source_position: Vector2) -> bool:
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


func _on_player_defeated(loser_id: int) -> void:
	if not round_active:
		return
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
		_start_round()
