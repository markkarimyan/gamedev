extends SceneTree

const GAME_SCENE := preload("res://scenes/Game.tscn")

var _failures := 0

func _initialize() -> void:
	await _test_players_gain_ultimate_charge_during_active_round()
	await _test_players_gain_ultimate_charge_from_combat()
	await _test_ultimate_readiness_reset_and_activation_gate()
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

	player_2.add_ultimate_charge(Player.MAX_ULTIMATE_CHARGE)
	game._unhandled_input(_key_press(KEY_SHIFT))
	_assert_true(activations[2] == 1, "Player 2 activates ultimate with Shift when ready")

	player_1.add_ultimate_charge(Player.MAX_ULTIMATE_CHARGE)
	player_1.reset_for_round(player_1.global_position)
	_assert_true(player_1.ultimate_charge == 0.0, "Ultimate charge resets for a new round")
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
