## pin_manager.gd
## Attach to: PinManager (Node3D) inside main.tscn
##
## Spawns the 10 bowling pins in the standard triangular formation,
## tracks which are knocked down, counts them, and resets them between rolls.
##
## Pin layout viewed from above (ball comes from -Z direction):
##
##   Row 4 (back):  7  8  9  10
##   Row 3:         4  5  6
##   Row 2:         2  3
##   Row 1 (front):    1
##
## Spacing between pin centres: 0.305 m (standard 12 inches).

extends Node3D

# ── Exports ───────────────────────────────────────────────────────────────────
## Scene to instantiate for each pin.
@export var pin_scene: PackedScene

## Z position of pin #1 (front pin).
@export var pin_area_z: float = 13.5

## Horizontal spacing between pin centres (metres).
@export var pin_spacing: float = 0.305

# ── Internal state ────────────────────────────────────────────────────────────
var _pins: Array[RigidBody3D] = []
var _knocked_count: int = 0

# Precalculated relative XZ offsets for each of the 10 pins.
# Index 0 = pin 1 (front), index 9 = pin 10 (back-right corner).
const PIN_OFFSETS: Array = [
	# Row 1
	Vector2(0.0,        0.0),
	# Row 2
	Vector2(-0.5,       1.0),
	Vector2( 0.5,       1.0),
	# Row 3
	Vector2(-1.0,       2.0),
	Vector2( 0.0,       2.0),
	Vector2( 1.0,       2.0),
	# Row 4
	Vector2(-1.5,       3.0),
	Vector2(-0.5,       3.0),
	Vector2( 0.5,       3.0),
	Vector2( 1.5,       3.0),
]


func _ready() -> void:
	if pin_scene == null:
		push_warning("PinManager: pin_scene is not assigned. Pins will not spawn.")
		return
	_spawn_pins()


# ── Spawning ──────────────────────────────────────────────────────────────────

func _spawn_pins() -> void:
	for i in range(10):
		var pin: RigidBody3D = pin_scene.instantiate()
		add_child(pin)

		# Calculate world position from offset
		var offset: Vector2 = PIN_OFFSETS[i]
		var spawn_pos := Vector3(
			global_position.x + offset.x * pin_spacing,
			global_position.y,          # PinManager y must be at lane surface
			pin_area_z + offset.y * pin_spacing
		)
		# setup() both places the pin and records _spawn_position for reset
		pin.setup(spawn_pos)
		pin.name = "Pin%d" % (i + 1)

		# Connect knocked signal
		pin.connect("pin_knocked", _on_pin_knocked)
		_pins.append(pin)


# ── Signals ───────────────────────────────────────────────────────────────────

func _on_pin_knocked(_pin: RigidBody3D) -> void:
	_knocked_count += 1


# ── Public API ────────────────────────────────────────────────────────────────

## Enable knock detection on all standing pins (call after ball is thrown).
func enable_detection() -> void:
	for pin in _pins:
		if not pin.is_knocked():
			pin.enable_knock_detection()


## Returns how many pins have been knocked down during this roll.
func get_knocked_count() -> int:
	return _knocked_count


## Returns how many pins are still standing.
func get_standing_count() -> int:
	var count := 0
	for pin in _pins:
		if not pin.is_knocked():
			count += 1
	return count


## Resets the knocked counter (call at the start of each roll).
func reset_knocked_count() -> void:
	_knocked_count = 0


## Resets all 10 pins to their original positions (call at the start of each frame).
func reset_all_pins() -> void:
	_knocked_count = 0
	for pin in _pins:
		pin.reset_pin()


## Re-enables detection on all currently standing pins after a short delay
## so the reset physics can settle.
func enable_detection_after_reset() -> void:
	await get_tree().create_timer(0.3).timeout
	enable_detection()
