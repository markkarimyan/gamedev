extends Node

const LEVELS := [
	{
		"name": "Campus",
		"background_path": "res://assets/university_background_pixel.png",
	},
	{
		"name": "Cast",
		"background_path": "res://assets/cast_bg.png",
	},
	{
		"name": "Art Lunch",
		"background_path": "res://assets/artlunch_bg.png",
	},
]

var winner_name := ""
var selected_level_index := 0


func get_selected_level() -> Dictionary:
	return LEVELS[selected_level_index]


func get_levels() -> Array:
	return LEVELS


func get_selected_level_index() -> int:
	return selected_level_index


func set_selected_level(index: int) -> void:
	selected_level_index = clampi(index, 0, LEVELS.size() - 1)
