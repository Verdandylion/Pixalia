## ui_manager.gd
## Attach to: HUDControl (Control node) inside the CanvasLayer in main.tscn
##
## Updates all on-screen labels: current frame, roll, score, aim/power hints,
## and temporary status messages (Strike!, Spare!, etc.)

extends Control

# ── Node references (must match the scene tree) ───────────────────────────────
@onready var frame_label: Label    = $TopInfo/FrameLabel
@onready var score_label: Label    = $TopInfo/ScoreLabel
@onready var turn_label: Label     = $TopInfo/TurnLabel
@onready var message_label: Label  = $TopInfo/MessageLabel
@onready var aim_label: Label      = $BottomControls/AimLabel
@onready var power_label: Label    = $BottomControls/PowerLabel

# Duration (seconds) before the message auto-clears
const MESSAGE_DURATION: float = 2.5

var _message_timer: float = 0.0


func _process(delta: float) -> void:
	if _message_timer > 0.0:
		_message_timer -= delta
		if _message_timer <= 0.0:
			message_label.text = ""


# ── Public update functions (called by GameManager) ───────────────────────────

## Updates the frame counter label.  frame_num is 1-10.
func update_frame(frame_num: int, roll_num: int) -> void:
	frame_label.text = "Frame: %d  Roll: %d" % [frame_num, roll_num]


## Updates the running score display.
func update_score(score: int) -> void:
	score_label.text = "Score: %d" % score


## Updates the turn / status line.
func update_turn(text: String) -> void:
	turn_label.text = text


## Shows a temporary highlighted message (Strike!, Spare!, etc.)
func show_message(text: String) -> void:
	message_label.text = text
	_message_timer = MESSAGE_DURATION


## Updates the aim indicator line.
func update_aim(angle_deg: float) -> void:
	var dir := "Center"
	if angle_deg < -3.0:
		dir = "Left  %.0f°" % abs(angle_deg)
	elif angle_deg > 3.0:
		dir = "Right %.0f°" % angle_deg
	aim_label.text = "Aim: %s" % dir


## Updates the power bar line.
func update_power(power: float, min_p: float, max_p: float) -> void:
	var pct := int(((power - min_p) / (max_p - min_p)) * 100.0)
	power_label.text = "Power: %d%%" % pct


## Shows controls hint when it's time to aim.
func show_aim_hint() -> void:
	aim_label.text   = "A/D — Aim   W/S — Power   SPACE — Throw"
	power_label.text = ""


## Hides the aim/power controls during rolling.
func hide_controls() -> void:
	aim_label.text   = ""
	power_label.text = ""
