extends SceneTree

const GAME_SCENE := preload("res://scenes/Game.tscn")
const BULLET_SCENE := preload("res://scenes/Bullet.tscn")

var _failures := 0

func _initialize() -> void:
	await _test_players_gain_ultimate_charge_during_active_round()
	await _test_players_gain_ultimate_charge_from_combat()
	await _test_ultimate_readiness_reset_and_activation_gate()
	await _test_ultimate_activation_runs_match_cinematic_freeze()
	await _test_bullets_pause_during_match_cinematic_freeze()
	_finish()


func _test_players_gain_ultimate_charge_during_active_round() -> void:
	var game := GAME_SCENE.instantiate()
	root.add_child(game)
	await process_frame
	await _process_seconds(1.1)

	var player_1: Player = game.get_node("%Player1")
	var player_2: Player = game.get_node("%Player2")
	_assert_true(player_1.ultimate_charge > 0.0, "Player 1 gains ultimate charge over time")
	_assert_true(player_2.ultimate_charge > 0.0, "Player 2 gains ultimate charge over time")
	game.queue_free()
	await process_frame


func _test_players_gain_ultimate_charge_from_combat() -> void:
	var game := GAME_SCENE.instantiate()
	root.add_child(game)
	await process_frame

	var player_1: Player = game.get_node("%Player1")
	var player_2: Player = game.get_node("%Player2")
	var p1_before := player_1.ultimate_charge
	var p2_before := player_2.ultimate_charge

	game.apply_player_hit(1, 2, 12, player_1.global_position)

	_assert_true(player_1.ultimate_charge > p1_before, "Player gains ultimate charge when dealing damage")
	_assert_true(player_2.ultimate_charge > p2_before, "Player gains ultimate charge when taking damage")
	game.queue_free()
	await process_frame


func _test_ultimate_readiness_reset_and_activation_gate() -> void:
	var game := GAME_SCENE.instantiate()
	root.add_child(game)
	await process_frame

	var player_1: Player = game.get_node("%Player1")
	var player_2: Player = game.get_node("%Player2")
	var hud: HUD = game.get_node("%HUD")
	var activations := {1: 0, 2: 0}
	player_1.ultimate_activated.connect(func(_player_id: int) -> void: activations[1] += 1)
	player_2.ultimate_activated.connect(func(_player_id: int) -> void: activations[2] += 1)

	player_1.add_ultimate_charge(99.0)
	game._unhandled_input(_key_press(KEY_G))
	_assert_true(activations[1] == 0, "Player 1 cannot activate ultimate before ready")

	player_1.add_ultimate_charge(1.0)
	_assert_true(hud.get_node("%P1UltimateLabel").text == "G READY", "HUD shows Player 1 ultimate ready state")
	game._unhandled_input(_key_press(KEY_G))
	_assert_true(activations[1] == 1, "Player 1 activates ultimate with G when ready")
	_assert_true(player_1.ultimate_charge == 0.0, "Ultimate charge is consumed after activation")
	await _wait_seconds(0.5)

	player_2.add_ultimate_charge(Player.MAX_ULTIMATE_CHARGE)
	game._unhandled_input(_key_press(KEY_SHIFT))
	_assert_true(activations[2] == 1, "Player 2 activates ultimate with Shift when ready")

	player_1.add_ultimate_charge(Player.MAX_ULTIMATE_CHARGE)
	player_1.reset_for_round(player_1.global_position)
	_assert_true(player_1.ultimate_charge == 0.0, "Ultimate charge resets for a new round")
	game.queue_free()
	await process_frame


func _test_ultimate_activation_runs_match_cinematic_freeze() -> void:
	var game := GAME_SCENE.instantiate()
	root.add_child(game)
	await process_frame

	var player_1: Player = game.get_node("%Player1")
	var player_2: Player = game.get_node("%Player2")
	var finished_ultimates: Array[int] = []
	game.ultimate_cinematic_finished.connect(func(player_id: int) -> void: finished_ultimates.append(player_id))

	player_1.add_ultimate_charge(Player.MAX_ULTIMATE_CHARGE)
	game._unhandled_input(_key_press(KEY_G))

	_assert_true(game.is_match_cinematic_frozen(), "Ultimate activation enters match cinematic freeze")
	_assert_true(not player_1.controls_enabled and not player_2.controls_enabled, "Players lose control during cinematic freeze")

	var p1_charge := player_1.ultimate_charge
	var p2_health := player_2.health
	var p2_position := player_2.global_position
	await _process_seconds(0.2)
	game.apply_player_hit(1, 2, 12, player_1.global_position)

	_assert_true(player_1.ultimate_charge == p1_charge, "Ultimate timing pauses during cinematic freeze")
	_assert_true(player_2.health == p2_health, "Gameplay damage is blocked during cinematic freeze")
	_assert_true(player_2.global_position == p2_position, "Players do not move during cinematic freeze")

	await _wait_seconds(0.4)
	_assert_true(not game.is_match_cinematic_frozen(), "Match cinematic freeze exits after setup")
	_assert_true(player_1.controls_enabled and player_2.controls_enabled, "Player control is restored after cinematic freeze")
	_assert_true(finished_ultimates == [1], "Cinematic freeze exposes a player-specific ultimate resolution hook")

	game.queue_free()
	await process_frame


func _test_bullets_pause_during_match_cinematic_freeze() -> void:
	var game := GAME_SCENE.instantiate()
	root.add_child(game)
	await process_frame

	var bullet := BULLET_SCENE.instantiate()
	bullet.owner_id = 1
	bullet.direction = 1
	bullet.speed = 600.0
	bullet.global_position = Vector2(300, 430)
	game.add_child(bullet)
	await process_frame

	game.start_ultimate_cinematic(1, 0.25)
	var frozen_position: Vector2 = bullet.global_position
	await _process_seconds(0.2)
	_assert_true(bullet.global_position == frozen_position, "Bullets pause during cinematic freeze")

	await _wait_seconds(0.3)
	await _process_seconds(0.1)
	_assert_true(bullet.global_position.x > frozen_position.x, "Bullets resume after cinematic freeze")

	game.queue_free()
	await process_frame


func _key_press(keycode: Key) -> InputEventKey:
	var event := InputEventKey.new()
	event.keycode = keycode
	event.pressed = true
	return event


func _process_seconds(seconds: float) -> void:
	var elapsed := 0.0
	while elapsed < seconds:
		await process_frame
		elapsed += 1.0 / 60.0


func _wait_seconds(seconds: float) -> void:
	await create_timer(seconds).timeout


func _assert_true(condition: bool, message: String) -> void:
	if condition:
		print("PASS: %s" % message)
	else:
		_failures += 1
		push_error("FAIL: %s" % message)


func _finish() -> void:
	if _failures > 0:
		quit(1)
	else:
		quit(0)
