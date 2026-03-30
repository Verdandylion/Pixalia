extends ProgressBar

# Oscillates value 0→100→0 while active = true.
# Call stop() to freeze the meter and retrieve the current value.

const OSCILLATE_SPEED: float = 80.0  # Units per second

var active: bool = false
var _direction: float = 1.0

func _ready() -> void:
	min_value = 0.0
	max_value = 100.0
	value = 0.0
	visible = false

func _process(delta: float) -> void:
	if not active:
		return
	value += _direction * OSCILLATE_SPEED * delta
	if value >= max_value:
		value = max_value
		_direction = -1.0
	elif value <= min_value:
		value = min_value
		_direction = 1.0

# Start oscillating.
func start() -> void:
	active = true
	visible = true
	value = 0.0
	_direction = 1.0

# Stop oscillating and return the current value as 0.0–1.0.
func stop() -> float:
	active = false
	return value / max_value
