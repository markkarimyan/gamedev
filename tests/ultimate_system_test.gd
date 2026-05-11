extends SceneTree

const GAME_SCENE := preload("res://scenes/Game.tscn")
const BULLET_SCENE := preload("res://scenes/Bullet.tscn")
const ARENA_SCENES: Array[PackedScene] = [
	preload("res://scenes/arenas/CampusArena.tscn"),
	preload("res://scenes/arenas/CourtyardArena.tscn"),
	preload("res://scenes/arenas/RooftopArena.tscn"),
]
const PLAYER_COLLISION_SIZE := Vector2(42, 86)
const PLAYER_COLLISION_OFFSET := Vector2(0, -43)
const PLATFORM_VISUAL_HORIZONTAL_PADDING := 6.0
const PLATFORM_VISUAL_BOTTOM_PADDING := 12.0
const PLATFORM_TOP_ALIGNMENT_TOLERANCE := 0.1

var _failures := 0

func _initialize() -> void:
	await _test_arena_uses_authored_reusable_structure()
	await _test_player_sprite_feet_align_with_collision_feet()
	await _test_authored_arena_platforms_match_collision_and_clear_spawns()
	await _test_match_randomizes_authored_arenas_between_rounds()
	await _test_players_gain_ultimate_charge_during_active_round()
	await _test_players_gain_ultimate_charge_from_combat()
	await _test_ultimate_readiness_reset_and_activation_gate()
	await _test_ultimate_activation_runs_match_cinematic_freeze()
	await _test_bullets_pause_during_match_cinematic_freeze()
	await _test_player_2_car_ultimate_sweeps_after_cinematic()
	await _test_player_1_coffee_overdrive_starts_after_drink_cinematic()
	await _test_player_1_coffee_overdrive_buffs_then_crashes()
	await _test_player_1_coffee_modifiers_clear_on_round_reset()
	_finish()


func _test_arena_uses_authored_reusable_structure() -> void:
	var game := GAME_SCENE.instantiate()
	root.add_child(game)
	await process_frame

	var arena: Node = game.get_node("%Arena")
	_assert_true(arena.has_node("Background"), "Arena has a dedicated decorative background container")
	_assert_true(arena.has_node("GameplayGeometry/Platforms"), "Arena has authored gameplay platform geometry")
	_assert_true(arena.has_node("Spawns/P1Spawn") and arena.has_node("Spawns/P2Spawn"), "Arena exposes authored player spawn markers")
	_assert_true(arena.has_node("Pickups/FamasPickup") and arena.has_node("Pickups/AkPickup") and arena.has_node("Pickups/JumpPickup"), "Arena keeps pickups in an authored pickup container")
	_assert_true(arena.has_node("FutureGimmick/Placeholder"), "Arena reserves a place for a future arena gimmick")
	_assert_true(game.get_node("%Player1").start_position == arena.get_node("Spawns/P1Spawn").global_position, "Player 1 round reset uses the authored arena spawn")
	_assert_true(game.get_node("%Player2").start_position == arena.get_node("Spawns/P2Spawn").global_position, "Player 2 round reset uses the authored arena spawn")

	game.queue_free()
	await process_frame


func _test_player_sprite_feet_align_with_collision_feet() -> void:
	var game := GAME_SCENE.instantiate()
	root.add_child(game)
	await process_frame

	for player: Player in [game.get_node("%Player1"), game.get_node("%Player2")]:
		var full_sprite: Sprite2D = player.get_node("%FullSprite")
		var sprite_bottom := full_sprite.global_position.y + full_sprite.texture.get_height() * full_sprite.scale.y * 0.5
		_assert_true(absf(sprite_bottom - player.global_position.y) <= 1.0, "Player %d sprite feet align with collision feet" % player.player_id)

	game.queue_free()
	await process_frame


func _test_authored_arena_platforms_match_collision_and_clear_spawns() -> void:
	for arena_scene in ARENA_SCENES:
		var arena := arena_scene.instantiate()
		root.add_child(arena)
		await process_frame

		var p1_spawn: Marker2D = arena.get_node("Spawns/P1Spawn")
		var p2_spawn: Marker2D = arena.get_node("Spawns/P2Spawn")
		var spawn_rects := [
			_player_rect_at_spawn(p1_spawn.global_position),
			_player_rect_at_spawn(p2_spawn.global_position),
		]

		for platform: StaticBody2D in arena.get_node("GameplayGeometry/Platforms").get_children():
			var shape_node := _first_child_of_type(platform, CollisionShape2D) as CollisionShape2D
			var visual := _first_child_of_type(platform, ColorRect) as ColorRect
			if shape_node == null or not shape_node.shape is RectangleShape2D:
				continue

			var shape_size := (shape_node.shape as RectangleShape2D).size
			var platform_rect := Rect2(shape_node.global_position - shape_size * 0.5, shape_size)
			if visual != null:
				var visual_rect := Rect2(visual.global_position, visual.size)
				_assert_true(visual_rect.position.x <= platform_rect.position.x - PLATFORM_VISUAL_HORIZONTAL_PADDING, "%s visual extends past the left side of its hitbox" % platform.name)
				_assert_true(visual_rect.end.x >= platform_rect.end.x + PLATFORM_VISUAL_HORIZONTAL_PADDING, "%s visual extends past the right side of its hitbox" % platform.name)
				_assert_true(absf(visual_rect.position.y - platform_rect.position.y) <= PLATFORM_TOP_ALIGNMENT_TOLERANCE, "%s visual top aligns with its hitbox top" % platform.name)
				_assert_true(visual_rect.end.y >= platform_rect.end.y + PLATFORM_VISUAL_BOTTOM_PADDING, "%s visual bottom extends below its hitbox" % platform.name)

			for spawn_rect in spawn_rects:
				_assert_true(not spawn_rect.intersects(platform_rect), "%s spawn areas are clear of platform hitboxes" % arena.name)

		arena.queue_free()
		await process_frame


func _test_match_randomizes_authored_arenas_between_rounds() -> void:
	var game := GAME_SCENE.instantiate()
	root.add_child(game)
	await process_frame

	var first_arena: Node = game.get_node("%Arena")
	var player_1: Player = game.get_node("%Player1")
	var player_2: Player = game.get_node("%Player2")
	player_1.add_ultimate_charge(Player.MAX_ULTIMATE_CHARGE)
	player_2.add_ultimate_charge(Player.MAX_ULTIMATE_CHARGE)

	game.round_number = 2
	game._start_round(true)

	var next_arena: Node = game.get_node("%Arena")
	_assert_true(next_arena != first_arena, "Round reset can swap in a different authored arena")
	_assert_true(next_arena.has_node("Background"), "Selected arena updates the background container")
	_assert_true(next_arena.has_node("GameplayGeometry/Platforms"), "Selected arena updates authored platforms")
	_assert_true(next_arena.has_node("Pickups"), "Selected arena updates authored pickups")
	_assert_true(player_1.start_position == next_arena.get_node("Spawns/P1Spawn").global_position, "Player 1 respawns at the selected arena spawn")
	_assert_true(player_2.start_position == next_arena.get_node("Spawns/P2Spawn").global_position, "Player 2 respawns at the selected arena spawn")
	_assert_true(player_1.ultimate_charge == 0.0 and player_2.ultimate_charge == 0.0, "Ultimate charge resets when a new arena is selected")
	_assert_true(game.score_1 == 0 and game.score_2 == 0 and game.round_number == 2, "Arena swaps preserve score progression and round number")

	await process_frame
	game.queue_free()
	await process_frame


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


func _test_player_2_car_ultimate_sweeps_after_cinematic() -> void:
	var game := GAME_SCENE.instantiate()
	root.add_child(game)
	await process_frame

	var player_1: Player = game.get_node("%Player1")
	var player_2: Player = game.get_node("%Player2")
	player_1.global_position = Vector2(280, 448)
	player_1.invulnerable_left = 0.0
	player_2.global_position = Vector2(640, 448)
	player_2.facing = -1
	var player_2_health := player_2.health
	var player_1_start_x := player_1.global_position.x

	player_2.add_ultimate_charge(Player.MAX_ULTIMATE_CHARGE)
	game._unhandled_input(_key_press(KEY_SHIFT))

	await _wait_seconds(0.5)
	_assert_true(player_1.health == Player.MAX_HEALTH, "Player 2 car ultimate cannot hit during cinematic setup")
	var car_nodes := game.get_tree().get_nodes_in_group("player_2_car_ultimate")
	_assert_true(car_nodes.size() == 1, "Player 2 car ultimate telegraphs after cinematic setup")
	if car_nodes.is_empty():
		game.queue_free()
		await process_frame
		return
	var car: Node2D = game.get_tree().get_first_node_in_group("player_2_car_ultimate")
	var starting_x := car.global_position.x
	_assert_true(starting_x > 960.0, "Player 2 car ultimate starts off-screen in the facing direction")

	await _wait_seconds(1.35)
	_assert_true(car.global_position.x < starting_x, "Player 2 car ultimate travels horizontally with Player 2 facing")
	_assert_true(player_1.health <= Player.MAX_HEALTH - 35, "Player 2 car ultimate deals heavy damage to Player 1")
	_assert_true(player_1.global_position.x < player_1_start_x - 20.0, "Player 2 car ultimate knocks Player 1 in the sweep direction")
	_assert_true(player_2.health == player_2_health, "Player 2 car ultimate ignores Player 2")

	await _wait_seconds(1.2)
	await process_frame
	_assert_true(game.get_tree().get_nodes_in_group("player_2_car_ultimate").is_empty(), "Player 2 car ultimate cleans itself up after the sweep")

	game.queue_free()
	await process_frame


func _test_player_1_coffee_overdrive_starts_after_drink_cinematic() -> void:
	var game := GAME_SCENE.instantiate()
	root.add_child(game)
	await process_frame

	var player_1: Player = game.get_node("%Player1")
	player_1.add_ultimate_charge(Player.MAX_ULTIMATE_CHARGE)
	game._unhandled_input(_key_press(KEY_G))

	_assert_true(game.is_match_cinematic_frozen(), "Player 1 coffee ultimate starts with a drink cinematic freeze")
	_assert_true(not player_1.is_coffee_overdrive_active(), "Player 1 coffee overdrive waits until the drink cinematic ends")

	await _wait_seconds(0.5)
	_assert_true(not game.is_match_cinematic_frozen(), "Player 1 coffee drink cinematic finishes before overdrive")
	_assert_true(player_1.is_coffee_overdrive_active(), "Player 1 coffee overdrive begins after the drink cinematic")

	game.queue_free()
	await process_frame


func _test_player_1_coffee_overdrive_buffs_then_crashes() -> void:
	var game := GAME_SCENE.instantiate()
	root.add_child(game)
	await process_frame

	var player_1: Player = game.get_node("%Player1")
	var normal_speed := player_1.current_movement_speed()
	var normal_jump := player_1.current_jump_velocity()
	var normal_cooldown := player_1.current_weapon_cooldown()
	var normal_damage := player_1.weapon_damage

	player_1.add_ultimate_charge(Player.MAX_ULTIMATE_CHARGE)
	game._unhandled_input(_key_press(KEY_G))
	await _wait_seconds(0.5)

	_assert_true(player_1.current_movement_speed() > normal_speed, "Player 1 coffee overdrive increases movement speed")
	_assert_true(player_1.current_jump_velocity() < normal_jump, "Player 1 coffee overdrive strengthens jumping")
	_assert_true(player_1.current_weapon_cooldown() < normal_cooldown, "Player 1 coffee overdrive increases shooting rate")
	_assert_true(player_1.weapon_damage == normal_damage, "Player 1 coffee overdrive does not add a damage multiplier")
	_assert_true(player_1.invulnerable_left <= 0.0, "Player 1 coffee overdrive does not add invincibility")

	await _wait_seconds(Player.COFFEE_OVERDRIVE_SECONDS + 0.1)
	_assert_true(not player_1.is_coffee_overdrive_active(), "Player 1 coffee overdrive expires")
	_assert_true(player_1.is_coffee_crashing(), "Player 1 coffee overdrive enters a crash state")
	_assert_true(player_1.current_movement_speed() < normal_speed, "Player 1 coffee crash reduces movement speed")
	_assert_true(player_1.current_jump_velocity() == normal_jump, "Player 1 coffee crash cleans up jump strength")
	_assert_true(player_1.current_weapon_cooldown() == normal_cooldown, "Player 1 coffee crash cleans up shooting rate")

	await _wait_seconds(Player.COFFEE_CRASH_SECONDS + 0.1)
	_assert_true(not player_1.is_coffee_crashing(), "Player 1 coffee crash expires")
	_assert_true(player_1.current_movement_speed() == normal_speed, "Player 1 coffee modifiers clean up after crash")

	game.queue_free()
	await process_frame


func _test_player_1_coffee_modifiers_clear_on_round_reset() -> void:
	var game := GAME_SCENE.instantiate()
	root.add_child(game)
	await process_frame

	var player_1: Player = game.get_node("%Player1")
	var normal_speed := player_1.current_movement_speed()
	player_1.add_ultimate_charge(Player.MAX_ULTIMATE_CHARGE)
	game._unhandled_input(_key_press(KEY_G))
	await _wait_seconds(0.5)
	_assert_true(player_1.is_coffee_overdrive_active(), "Player 1 coffee overdrive is active before reset cleanup")

	player_1.reset_for_round(player_1.global_position)
	_assert_true(not player_1.is_coffee_overdrive_active(), "Player 1 coffee overdrive clears on round reset")
	_assert_true(not player_1.is_coffee_crashing(), "Player 1 coffee crash clears on round reset")
	_assert_true(player_1.current_movement_speed() == normal_speed, "Player 1 coffee movement modifier clears on round reset")

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


func _player_rect_at_spawn(spawn_position: Vector2) -> Rect2:
	return Rect2(spawn_position + PLAYER_COLLISION_OFFSET - PLAYER_COLLISION_SIZE * 0.5, PLAYER_COLLISION_SIZE)


func _first_child_of_type(parent: Node, type: Variant) -> Node:
	for child in parent.get_children():
		if is_instance_of(child, type):
			return child
	return null


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
