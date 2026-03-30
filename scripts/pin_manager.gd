extends Node3D

# Manages spawning, resetting, and querying all 10 bowling pins.
# Pins are created programmatically to avoid manual scene editing.

const PIN_SCRIPT := preload("res://scripts/pin.gd")

const PIN_HEIGHT: float = 0.38
const PIN_RADIUS: float = 0.05
const PIN_MASS: float = 1.5
const PIN_BASE_Z: float = 8.0    # Far end of lane (toward back wall)
const PIN_SPACING: float = 0.305  # ~standard pin spacing scaled to scene

# Standard 10-pin triangle offsets from center (x, z relative to PIN_BASE_Z)
const PIN_OFFSETS: Array = [
	# Row 1 (front, closest to bowler)
	Vector2(0.0, 0.0),
	# Row 2
	Vector2(-0.153, 0.305),
	Vector2(0.153, 0.305),
	# Row 3
	Vector2(-0.305, 0.610),
	Vector2(0.0, 0.610),
	Vector2(0.305, 0.610),
	# Row 4 (back)
	Vector2(-0.458, 0.915),
	Vector2(-0.153, 0.915),
	Vector2(0.153, 0.915),
	Vector2(0.458, 0.915),
]

var pins: Array = []

func _ready() -> void:
	spawn_pins()

# Spawn all 10 pins at their triangle positions.
func spawn_pins() -> void:
	for i in range(10):
		var pin_node := _create_pin(i)
		var offset: Vector2 = PIN_OFFSETS[i]
		pin_node.position = Vector3(offset.x, PIN_HEIGHT * 0.5, PIN_BASE_Z + offset.y)
		add_child(pin_node)
		pins.append(pin_node)

# Build a single pin RigidBody3D with mesh and collision.
func _create_pin(index: int) -> RigidBody3D:
	var body := RigidBody3D.new()
	body.name = "Pin_%02d" % (index + 1)
	body.mass = PIN_MASS
	body.set_script(PIN_SCRIPT)

	# Mesh
	var mesh_instance := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = PIN_RADIUS * 0.6
	cyl.bottom_radius = PIN_RADIUS
	cyl.height = PIN_HEIGHT
	mesh_instance.mesh = cyl

	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 1.0, 1.0)  # White
	mesh_instance.material_override = mat
	body.add_child(mesh_instance)

	# Collision shape
	var col := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = PIN_RADIUS
	shape.height = PIN_HEIGHT
	col.shape = shape
	body.add_child(col)

	return body

# Count how many pins are currently fallen.
func count_fallen() -> int:
	var count: int = 0
	for pin in pins:
		if is_instance_valid(pin) and pin.is_fallen():
			count += 1
	return count

# Reset all pins (for new frame).
func reset_all_pins() -> void:
	for pin in pins:
		if is_instance_valid(pin):
			pin.reset_pin()

# Remove fallen pins from scene so they don't clutter the lane on the next roll.
# Standing pins are left untouched.
func hide_fallen_pins() -> void:
	var i: int = pins.size() - 1
	while i >= 0:
		var pin = pins[i]
		if is_instance_valid(pin) and pin.is_fallen():
			pin.queue_free()
			pins.remove_at(i)
		i -= 1

# Remove all pins and respawn fresh (for new frame start).
func clear_and_respawn() -> void:
	for pin in pins:
		if is_instance_valid(pin):
			pin.queue_free()
	pins.clear()
	spawn_pins()
