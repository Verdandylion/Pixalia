extends Node3D

# Main game state machine.
# States: AIMING → CHARGING → ROLLING → SETTLING → SCORING → RESETTING → AIMING (or GAME_OVER)

enum GamePhase {
	AIMING,
	CHARGING,
	ROLLING,
	SETTLING,
	SCORING,
	RESETTING,
	GAME_OVER
}

const SETTLE_TIMEOUT: float = 3.5    # Max wait for ball/pins to settle
const RESET_DELAY: float = 1.5       # Brief pause before next roll setup
const GAME_OVER_SCENE := "res://scenes/GameOver.tscn"

@onready var bowling_ball = $BowlingBall
@onready var pin_manager = $PinManager
@onready var hud = $HUD
@onready var ball_return_timer: Timer = $BallReturnTimer

var phase: GamePhase = GamePhase.AIMING
var _reset_timer: float = 0.0
var _fallen_before_roll: int = 0  # Fallen pin count before the current roll

func _ready() -> void:
	ball_return_timer.wait_time = SETTLE_TIMEOUT
	ball_return_timer.one_shot = true
	ball_return_timer.timeout.connect(_on_settle_timeout)
	_start_aiming()

func _process(delta: float) -> void:
	match phase:
		GamePhase.AIMING:
			_process_aiming()
		GamePhase.CHARGING:
			_process_charging()
		GamePhase.ROLLING:
			_process_rolling(delta)
		GamePhase.SETTLING:
			pass  # Timer handles this
		GamePhase.SCORING:
			pass  # Handled in one shot after settling
		GamePhase.RESETTING:
			_process_resetting(delta)
		GamePhase.GAME_OVER:
			pass

# ── AIMING ──────────────────────────────────────────────────────────────────

func _start_aiming() -> void:
	phase = GamePhase.AIMING
	bowling_ball.begin_aiming()
	hud.hide_power_meter()
	hud.set_prompt("Aim with ← →,  hold SPACE to charge")

func _process_aiming() -> void:
	if Input.is_action_just_pressed("ui_accept"):
		_start_charging()

# ── CHARGING ─────────────────────────────────────────────────────────────────

func _start_charging() -> void:
	phase = GamePhase.CHARGING
	bowling_ball.begin_charging()
	hud.show_power_meter()
	hud.set_prompt("Release SPACE to bowl!")

func _process_charging() -> void:
	if Input.is_action_just_released("ui_accept"):
		var power_value: float = hud.power_meter.stop()
		_start_rolling(power_value)

# ── ROLLING ──────────────────────────────────────────────────────────────────

func _start_rolling(power_value: float) -> void:
	phase = GamePhase.ROLLING
	_fallen_before_roll = pin_manager.count_fallen()
	bowling_ball.launch(power_value)
	hud.hide_power_meter()
	hud.set_prompt("A / D to spin")

func _process_rolling(_delta: float) -> void:
	# Wait for ball to leave the start area before watching for settle
	if bowling_ball.position.z > 0.0:
		phase = GamePhase.SETTLING
		ball_return_timer.start()

# ── SETTLING ─────────────────────────────────────────────────────────────────

func _on_settle_timeout() -> void:
	_do_scoring()

# ── SCORING ──────────────────────────────────────────────────────────────────

func _do_scoring() -> void:
	phase = GamePhase.SCORING
	ball_return_timer.stop()

	var fallen_this_roll: int = pin_manager.count_fallen() - _fallen_before_roll
	fallen_this_roll = max(0, fallen_this_roll)
	# Clamp to standing pins available before this roll
	fallen_this_roll = min(fallen_this_roll, 10 - _fallen_before_roll)

	Scoring.record_roll(fallen_this_roll)
	hud.set_prompt("Scored: %d pins" % fallen_this_roll)

	_reset_timer = 0.0
	phase = GamePhase.RESETTING

# ── RESETTING ────────────────────────────────────────────────────────────────

func _process_resetting(delta: float) -> void:
	_reset_timer += delta
	if _reset_timer < RESET_DELAY:
		return

	if GameState.is_game_over:
		_go_to_game_over()
		return

	var frame := GameState.current_frame
	var roll := GameState.roll_in_frame

	bowling_ball.reset_ball()

	if roll == 1:
		# Starting a new frame (either after a strike or after completing 2 rolls).
		pin_manager.clear_and_respawn()
	elif frame == 10:
		# 10th frame bonus roll: check if pins need a fresh set.
		# After a strike (roll_in_frame == 2) or after a strike/spare pair (roll_in_frame == 3),
		# reset all pins so bonus rolls have a full set.
		var r := GameState.all_rolls
		var idx := Scoring.tenth_frame_start_index()
		var first := r[idx] if idx < r.size() else 0
		var second := r[idx + 1] if idx + 1 < r.size() else 0
		if first == 10 or (roll == 3 and first + second >= 10):
			# Strike on first roll, or spare/second-strike entering third roll → fresh pins
			pin_manager.clear_and_respawn()
		else:
			# Non-strike first roll; keep standing pins for second roll
			pin_manager.hide_fallen_pins()
	else:
		# Frames 1-9, second roll: remove fallen pins, leave standing ones.
		pin_manager.hide_fallen_pins()

	_start_aiming()

# ── GAME OVER ────────────────────────────────────────────────────────────────

func _go_to_game_over() -> void:
	phase = GamePhase.GAME_OVER
	get_tree().change_scene_to_file(GAME_OVER_SCENE)
