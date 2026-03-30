extends Node

# Scoring autoload singleton.
# Pure 10-frame bowling scoring logic. Reads/writes GameState.all_rolls.

# Record a roll result and advance GameState frame/roll counters.
func record_roll(knocked_down: int) -> void:
	GameState.all_rolls.append(knocked_down)
	_advance_state(knocked_down)

# Advance frame and roll counters after a roll.
func _advance_state(knocked_down: int) -> void:
	var frame := GameState.current_frame
	var roll := GameState.roll_in_frame

	if frame < 10:
		# Frames 1-9: strike ends frame after 1 roll; otherwise 2 rolls.
		if roll == 1 and knocked_down == 10:
			# Strike: advance to next frame
			GameState.current_frame += 1
			GameState.roll_in_frame = 1
		elif roll == 2:
			GameState.current_frame += 1
			GameState.roll_in_frame = 1
		else:
			GameState.roll_in_frame += 1
	else:
		# 10th frame: up to 3 rolls
		if roll == 3:
			GameState.is_game_over = true
		elif roll == 2:
			var r := GameState.all_rolls
			var idx := tenth_frame_start_index()
			var first := r[idx] if idx < r.size() else 0
			var second := r[idx + 1] if idx + 1 < r.size() else 0
			# If first two rolls total 10+, a third roll is granted
			if first + second >= 10:
				GameState.roll_in_frame = 3
			else:
				GameState.is_game_over = true
		else:
			GameState.roll_in_frame += 1

# Calculate per-frame cumulative scores. Returns array of 10 values.
# Frames not yet calculable return -1.
func calculate_scores() -> Array:
	var rolls := GameState.all_rolls
	var scores: Array = []
	var roll_index: int = 0
	var cumulative: int = 0

	for frame in range(10):
		if roll_index >= rolls.size():
			scores.append(-1)
			continue

		if frame < 9:
			# Frames 1-9
			if rolls[roll_index] == 10:
				# Strike
				if roll_index + 2 < rolls.size():
					var frame_score := 10 + rolls[roll_index + 1] + rolls[roll_index + 2]
					cumulative += frame_score
					scores.append(cumulative)
					roll_index += 1
				else:
					scores.append(-1)
					roll_index += 1
			elif roll_index + 1 < rolls.size() and rolls[roll_index] + rolls[roll_index + 1] == 10:
				# Spare
				if roll_index + 2 < rolls.size():
					var frame_score := 10 + rolls[roll_index + 2]
					cumulative += frame_score
					scores.append(cumulative)
					roll_index += 2
				else:
					scores.append(-1)
					roll_index += 2
			else:
				# Normal
				if roll_index + 1 < rolls.size():
					var frame_score := rolls[roll_index] + rolls[roll_index + 1]
					cumulative += frame_score
					scores.append(cumulative)
					roll_index += 2
				else:
					scores.append(-1)
					roll_index += 2
		else:
			# 10th frame: sum up to 3 rolls
			var tenth_rolls: int = 0
			var tenth_sum: int = 0
			var first: int = 0
			var second: int = 0
			if roll_index < rolls.size():
				first = rolls[roll_index]
				tenth_sum += first
				tenth_rolls += 1
				if roll_index + 1 < rolls.size():
					second = rolls[roll_index + 1]
					tenth_sum += second
					tenth_rolls += 1
					if (first == 10 or first + second >= 10) and roll_index + 2 < rolls.size():
						tenth_sum += rolls[roll_index + 2]
						tenth_rolls += 1
			# Only display score when we have all rolls needed.
			var needs_bonus := (first == 10) or (tenth_rolls >= 2 and first + second >= 10)
			var ready := GameState.is_game_over or (needs_bonus and tenth_rolls >= 3) or (not needs_bonus and tenth_rolls >= 2)
			if ready:
				cumulative += tenth_sum
				scores.append(cumulative)
			else:
				scores.append(-1)

	return scores

# Returns the index in all_rolls where the 10th frame begins.
func tenth_frame_start_index() -> int:
	var rolls := GameState.all_rolls
	var idx: int = 0
	for frame in range(9):
		if idx < rolls.size() and rolls[idx] == 10:
			idx += 1  # Strike: one roll per frame
		else:
			idx += 2  # Normal/spare: two rolls per frame
	return idx

# Helper: total score so far (last calculable frame).
func total_score() -> int:
	var s := calculate_scores()
	var total: int = 0
	for v in s:
		if v >= 0:
			total = v
	return total
