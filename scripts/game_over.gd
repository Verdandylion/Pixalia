extends Control

# Game-over screen. Displays final score and offers Restart or Quit.

@onready var score_label: Label = $CenterContainer/VBoxContainer/FinalScoreLabel

func _ready() -> void:
	var total := Scoring.total_score()
	score_label.text = "Final Score: %d" % total

func _on_restart_pressed() -> void:
	GameState.reset()
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
