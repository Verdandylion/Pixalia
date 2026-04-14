## isometric_camera.gd
## Attach to: IsometricCamera (Camera3D) inside main.tscn
##
## Provides a fixed isometric-like overhead view of the bowling lane.
## Before the throw the camera stays at a locked overview position.
## After the throw it gently follows the ball along the lane (Z axis only)
## so players can track the ball without losing the sense of direction.

extends Camera3D

# ── Exported variables (tweak in the Inspector) ──────────────────────────────

## Distance from the target point behind the lane centre.
@export var camera_distance: float = 8.0

## Height above the lane floor.
@export var camera_height: float = 10.0

## Horizontal offset from lane centre (0 = centred).
@export var horizontal_offset: float = 0.0

## How smoothly the camera moves toward its target (lower = smoother / slower).
@export var smoothing_speed: float = 5.0

## How strongly the camera follows the ball along Z after throw (0 = no follow, 1 = full).
@export var follow_strength: float = 0.4

## Maximum Z the camera target will follow the ball to (prevents flying past pins).
@export var max_follow_z: float = 10.0

# ── Internal ──────────────────────────────────────────────────────────────────
## The point in the lane the camera looks at when no ball is thrown.
## Set this to the centre of the lane (e.g. z = 7 for an 18 m lane).
@export var overview_look_target: Vector3 = Vector3(0.0, 0.0, 7.0)

var _follow_target: Node3D = null   # assigned by GameManager after throw
var _current_look_z: float = 0.0    # interpolated Z of look target
var _following: bool = false


func _ready() -> void:
	_current_look_z = overview_look_target.z
	_update_camera_position(overview_look_target)


func _process(delta: float) -> void:
	var desired_look_z := overview_look_target.z

	if _following and _follow_target != null:
		# Lerp toward ball's Z position, clamped so we don't overshoot pins
		var ball_z := clamp(_follow_target.global_position.z, overview_look_target.z, max_follow_z)
		desired_look_z = lerp(overview_look_target.z, ball_z, follow_strength)

	# Smoothly move current look Z toward desired
	_current_look_z = lerp(_current_look_z, desired_look_z, smoothing_speed * delta)

	var look_at_point := Vector3(0.0, 0.0, _current_look_z)
	_update_camera_position(look_at_point)


func _update_camera_position(look_at_point: Vector3) -> void:
	# Position the camera behind and above the look point.
	# horizontal_offset shifts the camera sideways without moving the look target.
	var cam_pos := Vector3(
		horizontal_offset,
		look_at_point.y + camera_height,
		look_at_point.z - camera_distance
	)
	global_position = cam_pos
	# Always look at the centre of the lane at the target Z
	look_at(look_at_point, Vector3.UP)


# ── Public API (called by GameManager) ────────────────────────────────────────

## Call after the ball is thrown to start gently following it.
func start_follow(ball: Node3D) -> void:
	_follow_target = ball
	_following = true


## Call when the ball has stopped to return to the overview position.
func stop_follow() -> void:
	_following = false
	_follow_target = null
