extends CanvasLayer

# Updates all HUD labels each frame from GameState and Scoring.

@onready var score_label: Label = $ScoreLabel
@onready var frame_label: Label = $FrameLabel
@onready var roll_label: Label = $RollLabel
@onready var prompt_label: Label = $PromptLabel
@onready var power_meter: ProgressBar = $PowerMeter

func _process(_delta: float) -> void:
	var scores := Scoring.calculate_scores()
	var display_score: int = 0
	for s in scores:
		if s >= 0:
			display_score = s

	score_label.text = "Score: %d" % display_score
	frame_label.text = "Frame: %d / 10" % GameState.current_frame
	roll_label.text = "Roll: %d" % GameState.roll_in_frame

# Show the power meter and start oscillation.
func show_power_meter() -> void:
	power_meter.start()

# Hide the power meter.
func hide_power_meter() -> void:
	power_meter.visible = false
	power_meter.active = false

# Set the prompt message shown to the player.
func set_prompt(text: String) -> void:
	prompt_label.text = text
