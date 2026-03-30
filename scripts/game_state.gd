extends Node

# GameState autoload singleton.
# Tracks current frame, roll within frame, all rolls, and game-over state.

var current_frame: int = 1       # 1-10
var roll_in_frame: int = 1       # 1-3 (3 only possible in 10th frame)
var all_rolls: Array = []        # All rolls recorded as pin counts
var frame_scores: Array = []     # Calculated scores per frame (filled by Scoring)
var is_game_over: bool = false

func _ready() -> void:
	reset()

func reset() -> void:
	current_frame = 1
	roll_in_frame = 1
	all_rolls = []
	frame_scores = []
	is_game_over = false
