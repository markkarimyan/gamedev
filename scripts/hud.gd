extends CanvasLayer
class_name HUD

@onready var p1_health: ProgressBar = %P1Health
@onready var p2_health: ProgressBar = %P2Health
@onready var p1_score: Label = %P1Score
@onready var p2_score: Label = %P2Score
@onready var round_label: Label = %RoundLabel
@onready var message_label: Label = %MessageLabel

func set_health(player_id: int, health: int, max_health: int) -> void:
	var bar := p1_health if player_id == 1 else p2_health
	bar.max_value = max_health
	bar.value = health


func set_scores(score_1: int, score_2: int, target_score: int) -> void:
	p1_score.text = "P1: %d/%d" % [score_1, target_score]
	p2_score.text = "P2: %d/%d" % [score_2, target_score]


func set_round(round_number: int) -> void:
	round_label.text = "Round %d" % round_number


func show_message(text: String) -> void:
	message_label.text = text


func clear_message() -> void:
	message_label.text = ""
