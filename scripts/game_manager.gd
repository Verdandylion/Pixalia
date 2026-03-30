## game_manager.gd
## Attach to: Main (Node3D) — the root node of main.tscn
##
## Orchestrates the full turn-based bowling loop:
##   AIMING  → (throw)  → ROLLING  → (stopped) → SCORING
##   → next roll or next frame → AIMING  …
##
## Handles:
##   • 10-frame game with correct strike / spare bonus scoring
##   • 10th frame: up to 3 rolls if a strike or spare is scored
##   • Communication with BowlingBall, PinManager, Camera, and UI

extends Node3D

# ── Game-state enum ──────────────────────────────────────────────────────────
enum State { AIMING, ROLLING, SCORING, GAME_OVER }

# ── Node references (paths must match the scene tree) ────────────────────────
@onready var ball: RigidBody3D     = $BowlingBall
@onready var pin_manager: Node3D   = $PinManager
@onready var camera: Camera3D      = $IsometricCamera
@onready var hud: Control          = $HUD/HUDControl

# ── State ─────────────────────────────────────────────────────────────────────
var _state: State = State.AIMING

## Flat list of every individual roll result (used for official scoring).
var _rolls: Array[int] = []

## Current frame index (0 – 9).
var _current_frame: int = 0

## Roll index within the current frame (0 or 1; up to 2 in frame 10).
var _roll_in_frame: int = 0

## Pins knocked on the first roll of this frame (needed to limit second-roll pins).
var _frame_first_roll_knocked: int = 0

## Running total displayed to the player (real bowling score needs look-ahead).
var _running_score: int = 0

# ── Delay settings ────────────────────────────────────────────────────────────
const SCORING_DELAY: float = 1.5   # seconds after ball stops before scoring
const RESET_DELAY:   float = 1.0   # seconds after message before resetting


func _ready() -> void:
	# Wire up ball signals
	ball.connect("ball_thrown", _on_ball_thrown)
	ball.connect("ball_stopped", _on_ball_stopped)

	_start_aiming()


# ── State transitions ─────────────────────────────────────────────────────────

func _start_aiming() -> void:
	_state = State.AIMING
	ball.reset_ball()
	pin_manager.reset_knocked_count()
	ball.allow_input = true

	var frame_display := _current_frame + 1
	var roll_display  := _roll_in_frame + 1
	hud.update_frame(frame_display, roll_display)
	hud.update_score(_calculate_score())
	hud.update_turn("Your turn! Aim and throw.")
	hud.show_aim_hint()


func _on_ball_thrown() -> void:
	_state = State.ROLLING
	hud.hide_controls()
	hud.update_turn("Ball is rolling…")
	camera.start_follow(ball)
	# Give pins knock-detection after a brief moment so the throw impulse settles
	await get_tree().create_timer(0.2).timeout
	pin_manager.enable_detection()


func _on_ball_stopped() -> void:
	camera.stop_follow()
	_state = State.SCORING
	await get_tree().create_timer(SCORING_DELAY).timeout
	_score_roll()


# ── Scoring logic ─────────────────────────────────────────────────────────────

func _score_roll() -> void:
	var knocked: int = pin_manager.get_knocked_count()
	_rolls.append(knocked)

	var is_frame_10: bool = (_current_frame == 9)

	if _roll_in_frame == 0:
		# ── First roll of a frame ──────────────────────────────────────────
		_frame_first_roll_knocked = knocked

		if knocked == 10 and not is_frame_10:
			# Strike — frame is over
			hud.show_message("STRIKE! 🎳")
			await get_tree().create_timer(RESET_DELAY).timeout
			_advance_to_next_frame()
		else:
			# Not a strike (or frame 10 where you always get a second roll)
			if knocked == 10:
				hud.show_message("STRIKE! 🎳")
				# Frame 10, first-roll strike: reset all 10 pins for roll 2
				pin_manager.reset_all_pins()
				await pin_manager.enable_detection_after_reset()
			_roll_in_frame = 1
			# Keep knocked pins down (non-strike); only reset the counter
			pin_manager.reset_knocked_count()
			_start_aiming()
	else:
		# ── Second roll of a frame ─────────────────────────────────────────
		var total_this_frame: int = _frame_first_roll_knocked + knocked

		if is_frame_10:
			_handle_10th_frame_scoring(knocked, total_this_frame)
		else:
			if total_this_frame == 10:
				hud.show_message("SPARE! ✨")
			else:
				hud.show_message("Roll 2: %d pins" % knocked)
			await get_tree().create_timer(RESET_DELAY).timeout
			_advance_to_next_frame()


## Special handling for the 10th frame (up to 3 rolls).
func _handle_10th_frame_scoring(knocked: int, total_this_frame: int) -> void:
	if _roll_in_frame == 1:
		# After roll 2 in frame 10.
		# Bonus roll is earned if roll 1 was a strike OR rolls 1+2 = spare.
		if _frame_first_roll_knocked == 10 or total_this_frame == 10:
			# Strike on roll 1 (any second roll) or spare → bonus roll earned
			if _frame_first_roll_knocked == 10 and knocked == 10:
				hud.show_message("STRIKE AGAIN! 🎳 Bonus roll coming!")
			elif total_this_frame == 10:
				hud.show_message("SPARE! ✨ Bonus roll coming!")
			else:
				hud.show_message("Roll 2: %d pins — Bonus roll coming!" % knocked)
			await get_tree().create_timer(RESET_DELAY).timeout
			_roll_in_frame = 2
			# Reset pins for the bonus roll
			pin_manager.reset_all_pins()
			await pin_manager.enable_detection_after_reset()
			pin_manager.reset_knocked_count()
			_start_aiming()
		else:
			hud.show_message("Roll 2: %d pins" % knocked)
			await get_tree().create_timer(RESET_DELAY).timeout
			_end_game()
	elif _roll_in_frame == 2:
		# Bonus roll done
		if knocked == 10:
			hud.show_message("BONUS STRIKE! 🎳")
		else:
			hud.show_message("Bonus roll: %d pins" % knocked)
		await get_tree().create_timer(RESET_DELAY).timeout
		_end_game()


func _advance_to_next_frame() -> void:
	_current_frame += 1
	_roll_in_frame = 0
	_frame_first_roll_knocked = 0

	if _current_frame >= 10:
		_end_game()
		return

	pin_manager.reset_all_pins()
	# Wait for pins to settle after reset before enabling detection
	await pin_manager.enable_detection_after_reset()
	_start_aiming()


func _end_game() -> void:
	_state = State.GAME_OVER
	var final_score := _calculate_score()
	hud.update_score(final_score)
	hud.update_turn("Game over! Press SPACE to play again.")
	hud.show_message("Final score: %d" % final_score)
	# Listen for restart
	set_process_unhandled_input(true)


func _unhandled_input(event: InputEvent) -> void:
	if _state == State.GAME_OVER:
		if event.is_action_pressed("throw_ball"):
			_restart_game()


func _restart_game() -> void:
	_rolls.clear()
	_current_frame = 0
	_roll_in_frame = 0
	_frame_first_roll_knocked = 0
	_running_score = 0
	set_process_unhandled_input(false)
	pin_manager.reset_all_pins()
	await pin_manager.enable_detection_after_reset()
	_start_aiming()


# ── Official bowling score calculator ─────────────────────────────────────────
## Implements the look-ahead bonus scoring for strikes and spares.
func _calculate_score() -> int:
	var score := 0
	var roll_index := 0

	for frame in range(10):
		if roll_index >= _rolls.size():
			break

		if _rolls[roll_index] == 10:
			# Strike
			score += 10
			if roll_index + 1 < _rolls.size():
				score += _rolls[roll_index + 1]
			if roll_index + 2 < _rolls.size():
				score += _rolls[roll_index + 2]
			roll_index += 1
		elif roll_index + 1 < _rolls.size() and \
			 _rolls[roll_index] + _rolls[roll_index + 1] == 10:
			# Spare
			score += 10
			if roll_index + 2 < _rolls.size():
				score += _rolls[roll_index + 2]
			roll_index += 2
		else:
			score += _rolls[roll_index]
			if roll_index + 1 < _rolls.size():
				score += _rolls[roll_index + 1]
			roll_index += 2

	return score


# ── Live UI update (aim/power) ────────────────────────────────────────────────

func _process(_delta: float) -> void:
	if _state == State.AIMING:
		hud.update_aim(ball.get_aim_angle())
		hud.update_power(ball.get_power(), ball.min_power, ball.max_power)
