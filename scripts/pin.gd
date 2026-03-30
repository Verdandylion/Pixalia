extends RigidBody3D

# Attached to each Pin RigidBody3D.
# Detects if the pin has fallen over (tilt > 45 degrees from upright).

var original_position: Vector3 = Vector3.ZERO
var original_rotation: Vector3 = Vector3.ZERO

const FALL_ANGLE_DEG: float = 45.0

func _ready() -> void:
	original_position = global_position
	original_rotation = global_rotation

# Returns true if the pin has tipped more than 45 degrees from upright.
func is_fallen() -> bool:
	# The pin's Y axis in world space; if it deviates > 45° from Vector3.UP, it's fallen.
	var up_world := global_transform.basis.y.normalized()
	var angle := rad_to_deg(up_world.angle_to(Vector3.UP))
	return angle > FALL_ANGLE_DEG

# Reset pin to its original position and rotation, and stop physics motion.
func reset_pin() -> void:
	global_position = original_position
	global_rotation = original_rotation
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
