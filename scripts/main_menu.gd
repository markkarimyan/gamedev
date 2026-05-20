extends Control

@onready var start_button: Button = %StartButton
@onready var level_select: OptionButton = %LevelSelect

func _ready() -> void:
	_populate_level_select()
	start_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ENTER or event.keycode == KEY_SPACE:
			if level_select.has_focus():
				return
			_start_game()


func _populate_level_select() -> void:
	var game_state := get_node("/root/GameState")
	level_select.clear()
	for level in game_state.get_levels():
		level_select.add_item(level["name"])
	level_select.select(game_state.get_selected_level_index())


func _on_level_select_item_selected(index: int) -> void:
	get_node("/root/GameState").set_selected_level(index)


func _on_start_button_pressed() -> void:
	_start_game()


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _start_game() -> void:
	get_tree().change_scene_to_file("res://scenes/Game.tscn")
