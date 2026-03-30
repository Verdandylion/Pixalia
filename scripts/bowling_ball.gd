extends RigidBody3D

# Bowling ball controller.
# States: IDLE → AIMING → CHARGING → ROLLING
# AIMING: left/right arrows move ball on X axis.
# CHARGING: hold Space, power meter oscillates. Release to launch.
# ROLLING: optional A/D spin; ball travels forward.

enum State { IDLE, AIMING, CHARGING, ROLLING }

const BALL_RADIUS: float = 0.11
const LAUNCH_FORCE_MIN: float = 8.0
const LAUNCH_FORCE_MAX: float = 22.0
const AIM_SPEED: float = 1.2          # m/s lateral movement speed
const AIM_LIMIT: float = 0.38          # Max X offset from center (lane half-width minus margin)
const SPIN_TORQUE: float = 3.0         # Applied per-frame when A/D held during roll
const START_POSITION: Vector3 = Vector3(0.0, 0.11, -8.0)

var state: State = State.IDLE
var power: float = 0.0  # 0.0–1.0, set by power meter before launch

func _ready() -> void:
	freeze = true  # Keep ball static until launched
	position = START_POSITION

# Called each physics frame.
func _physics_process(delta: float) -> void:
	match state:
		State.AIMING:
			_handle_aiming(delta)
		State.ROLLING:
			_handle_spin(delta)

func _handle_aiming(delta: float) -> void:
	if Input.is_action_pressed("ui_left"):
		position.x -= AIM_SPEED * delta
	if Input.is_action_pressed("ui_right"):
		position.x += AIM_SPEED * delta
	position.x = clamp(position.x, -AIM_LIMIT, AIM_LIMIT)

func _handle_spin(delta: float) -> void:
	if Input.is_action_pressed("spin_left"):
		apply_torque(Vector3(0.0, 0.0, SPIN_TORQUE))
	if Input.is_action_pressed("spin_right"):
		apply_torque(Vector3(0.0, 0.0, -SPIN_TORQUE))

# Called from game.gd to start aiming.
func begin_aiming() -> void:
	state = State.AIMING
	freeze = true
	position = START_POSITION
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

# Called from game.gd to start charging (power meter animates externally).
func begin_charging() -> void:
	state = State.CHARGING

# Launch the ball. power_value is 0.0–1.0 from the power meter.
func launch(power_value: float) -> void:
	power = power_value
	var force := lerp(LAUNCH_FORCE_MIN, LAUNCH_FORCE_MAX, power)
	freeze = false
	state = State.ROLLING
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	apply_central_impulse(Vector3(0.0, 0.0, force))

# Return ball to start position and reset physics.
func reset_ball() -> void:
	state = State.IDLE
	freeze = true
	position = START_POSITION
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	rotation = Vector3.ZERO

# Returns true when the ball has nearly stopped moving.
func is_settled() -> bool:
	return linear_velocity.length() < 0.2
