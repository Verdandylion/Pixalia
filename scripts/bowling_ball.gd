## bowling_ball.gd
## Attach to: BowlingBall (RigidBody3D) node inside bowling_ball.tscn
##
## Handles aiming (left/right), power adjustment, throw, spin, and reset.
## The GameManager calls public methods here; input is read inside this script
## only during the AIMING phase (controlled via allow_input flag).

extends RigidBody3D

# ── Signals ─────────────────────────────────────────────────────────────────
## Emitted as soon as the throw happens.
signal ball_thrown
## Emitted when the ball comes to rest after being thrown.
signal ball_stopped

# ── Exported variables (tweak in the Inspector) ─────────────────────────────
## Physics feel
@export var ball_mass: float = 6.0          # kg — a real ball is 6-7 kg
@export var ball_friction: float = 0.5
@export var ball_bounce: float = 0.0

## Aiming
@export var aim_speed: float = 60.0         # degrees per second
@export var max_aim_angle: float = 30.0     # degrees left or right of centre

## Power
@export var min_power: float = 6.0          # m/s launch speed
@export var max_power: float = 14.0         # m/s launch speed
@export var power_change_speed: float = 4.0 # units/s

## Spin (optional sideways curve after launch)
@export var max_spin: float = 3.0           # angular velocity on Y axis

# ── Internal state ───────────────────────────────────────────────────────────
var _aim_angle: float = 0.0        # current horizontal aim in degrees
var _power: float = 10.0           # current launch power (m/s)
var _spin_amount: float = 0.0      # right = positive, left = negative
var _has_thrown: bool = false
var _is_rolling: bool = false
var _spawn_transform: Transform3D  # saved at _ready for reset

## Set to true by GameManager when aiming controls should be active.
var allow_input: bool = false

# ── Helpers ──────────────────────────────────────────────────────────────────
# Placeholder: attach an AimIndicator (e.g. a rotated arrow mesh) as a child
# of the ball to visually show the aim direction in the 3-D world.
# The node is optional — the script works fine without it.
@onready var _aim_indicator: Node3D = get_node_or_null("AimIndicator")


func _ready() -> void:
	mass = ball_mass
	physics_material_override = PhysicsMaterial.new()
	physics_material_override.friction = ball_friction
	physics_material_override.bounce = ball_bounce
	_spawn_transform = global_transform
	freeze = true  # hold in place until thrown


func _physics_process(delta: float) -> void:
	if allow_input and not _has_thrown:
		_handle_aim_input(delta)

	if _is_rolling:
		_check_if_stopped()


# ── Input handling ────────────────────────────────────────────────────────────

func _handle_aim_input(delta: float) -> void:
	# Aim left / right
	if Input.is_action_pressed("aim_left"):
		_aim_angle = clamp(_aim_angle - aim_speed * delta, -max_aim_angle, max_aim_angle)
	if Input.is_action_pressed("aim_right"):
		_aim_angle = clamp(_aim_angle + aim_speed * delta, -max_aim_angle, max_aim_angle)

	# Power up / down
	if Input.is_action_pressed("increase_power"):
		_power = clamp(_power + power_change_speed * delta, min_power, max_power)
	if Input.is_action_pressed("decrease_power"):
		_power = clamp(_power - power_change_speed * delta, min_power, max_power)

	# Optional spin (hold aim while pressing a modifier — here using the same keys
	# but combined with Shift to keep the binding count low for beginners)
	# The spin is stored and applied at launch.
	_spin_amount = (_aim_angle / max_aim_angle) * max_spin

	# Rotate the ball node visually to show aim direction
	rotation_degrees.y = -_aim_angle

	# Throw on Space
	if Input.is_action_just_pressed("throw_ball"):
		throw_ball()


# ── Public API (called by GameManager) ───────────────────────────────────────

## Throws the ball in the aimed direction with the current power.
func throw_ball() -> void:
	if _has_thrown:
		return
	_has_thrown = true
	allow_input = false
	freeze = false

	# Convert aim angle to a direction in the XZ plane (ball travels in +Z)
	var dir := Vector3(sin(deg_to_rad(_aim_angle)), 0.0, cos(deg_to_rad(_aim_angle))).normalized()
	# Small downward component keeps the ball on the lane
	dir.y = -0.02
	apply_impulse(dir * _power * mass)

	# Apply spin as angular velocity around Y (creates hook effect)
	angular_velocity = Vector3(0.0, _spin_amount, 0.0)

	_is_rolling = true
	emit_signal("ball_thrown")


## Resets the ball to its spawn transform, ready for the next roll.
func reset_ball() -> void:
	freeze = true
	_has_thrown = false
	_is_rolling = false
	allow_input = false
	_aim_angle = 0.0
	_power = 10.0
	_spin_amount = 0.0
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	global_transform = _spawn_transform
	rotation_degrees = Vector3.ZERO


# ── Getters used by UI ────────────────────────────────────────────────────────

func get_aim_angle() -> float:
	return _aim_angle


func get_power() -> float:
	return _power


func has_thrown() -> bool:
	return _has_thrown


# ── Internal helpers ──────────────────────────────────────────────────────────

func _check_if_stopped() -> void:
	# Ball is "stopped" when both linear and angular speeds drop below thresholds
	if linear_velocity.length() < 0.15 and angular_velocity.length() < 0.2:
		_is_rolling = false
		emit_signal("ball_stopped")
