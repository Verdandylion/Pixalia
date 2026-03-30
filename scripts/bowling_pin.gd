## bowling_pin.gd
## Attach to: each BowlingPin (RigidBody3D) node inside bowling_pin.tscn
##
## Tracks whether this pin has been knocked down by checking
## if it has tilted significantly or moved from its spawn position.
## Emits "pin_knocked" so PinManager can count knocked pins.

extends RigidBody3D

# Emitted once when this pin is considered knocked down
signal pin_knocked(pin: RigidBody3D)

# A pin is "knocked" if its up-vector (global Y) deviates more than this
# angle (in degrees) from world-up, or if it has moved far from its origin.
@export var knocked_angle_threshold: float = 40.0
@export var knocked_distance_threshold: float = 0.3

var _spawn_position: Vector3 = Vector3.ZERO
var _is_knocked: bool = false
var _check_enabled: bool = false   # only start checking after the throw


func _ready() -> void:
	# _spawn_position is set by PinManager via setup() after positioning.
	pass


## Called by PinManager immediately after the pin is placed in the world.
## Records the authoritative spawn position used for reset.
func setup(spawn_pos: Vector3) -> void:
	global_position = spawn_pos
	_spawn_position = spawn_pos


## Called by PinManager after the ball is thrown so we don't false-positive
## during the spawn settling phase.
func enable_knock_detection() -> void:
	_check_enabled = true


func _physics_process(_delta: float) -> void:
	if _is_knocked or not _check_enabled:
		return

	# Check tilt: dot product of the pin's local Y axis with world Y
	var up_dot := global_transform.basis.y.dot(Vector3.UP)
	var angle := rad_to_deg(acos(clamp(up_dot, -1.0, 1.0)))

	# Check displacement from spawn
	var displacement := global_position.distance_to(_spawn_position)

	if angle > knocked_angle_threshold or displacement > knocked_distance_threshold:
		_is_knocked = true
		emit_signal("pin_knocked", self)


## Returns true if this pin has been knocked down.
func is_knocked() -> bool:
	return _is_knocked


## Resets the pin to its original spawn position, standing upright.
func reset_pin() -> void:
	_is_knocked = false
	_check_enabled = false

	# Restore transform: move back to spawn, reset rotation, stop motion
	global_position = _spawn_position
	global_rotation = Vector3.ZERO
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

	# Freeze briefly so physics doesn't immediately tip the pin
	freeze = true
	await get_tree().create_timer(0.1).timeout
	freeze = false
