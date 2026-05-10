extends Control

@onready var start_button: Button = %StartButton

func _ready() -> void:
	start_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ENTER or event.keycode == KEY_SPACE:
			_start_game()


func _on_start_button_pressed() -> void:
	_start_game()


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _start_game() -> void:
	get_tree().change_scene_to_file("res://scenes/Game.tscn")
