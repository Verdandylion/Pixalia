# Pixalia Bowling

A small **isometric 3-D bowling game** built with **Godot 4** and **GDScript**.

---

## How to Open & Play

1. Install [Godot 4.2+](https://godotengine.org/download).
2. Open Godot, click **Import**, and select `project.godot` in this folder.
3. Press **F5** (or the ▶ button) to run.

### Controls

| Key | Action |
|-----|--------|
| **A** / ← | Aim left |
| **D** / → | Aim right |
| **W** / ↑ | Increase power |
| **S** / ↓ | Decrease power |
| **Space** | Throw ball / restart after game over |

---

## Project Structure

```
Pixalia/
├── project.godot               ← Godot 4 project config + input map
├── scenes/
│   ├── main.tscn               ← Main scene (root of the game)
│   ├── bowling_lane.tscn       ← Lane, gutters, back wall
│   ├── bowling_ball.tscn       ← RigidBody3D ball with material
│   └── bowling_pin.tscn        ← RigidBody3D pin with material
└── scripts/
    ├── game_manager.gd         ← Turn flow, 10-frame scoring, strike/spare
    ├── isometric_camera.gd     ← Fixed angle + gentle ball follow
    ├── bowling_ball.gd         ← Aim, power, spin, throw, reset
    ├── bowling_pin.gd          ← Knock detection + reset
    ├── pin_manager.gd          ← Spawn 10 pins, count, reset formation
    └── ui_manager.gd           ← Score / frame / hint labels
```

---

## Scene Node Tree (`main.tscn`)

```
Main  (Node3D)  ←  game_manager.gd
├── WorldEnvironment            ← procedural sky + ambient light
├── SunLight  (DirectionalLight3D)
├── IsometricCamera  (Camera3D)  ←  isometric_camera.gd
│       Fixed angle, gentle follow after throw
├── BowlingLane  (Node3D)  ←  bowling_lane.tscn instance
│   ├── LaneFloor   (StaticBody3D)  18 m × 1.05 m wooden lane
│   ├── LeftGutter  (StaticBody3D)  0.25 m wide recessed gutter
│   ├── RightGutter (StaticBody3D)
│   ├── BackWall    (StaticBody3D)  stops ball behind pins
│   ├── LeftWall / RightWall        invisible side barriers
│   └── FoulLine    (MeshInstance3D) red visual stripe at z = 0
├── BallSpawnPoint  (Marker3D)  at z = 0.5, y = 0.108
├── BowlingBall  (RigidBody3D)  ←  bowling_ball.tscn + bowling_ball.gd
│   ├── BallMesh       (MeshInstance3D)  sphere r = 0.108 m
│   └── BallCollision  (CollisionShape3D)
├── PinManager  (Node3D)  ←  pin_manager.gd
│   └── (10 × BowlingPin spawned at runtime in triangular formation)
│       Each pin: RigidBody3D  ←  bowling_pin.gd
│           ├── PinMesh      (MeshInstance3D)  cylinder h=0.38 m
│           └── PinCollision (CollisionShape3D)
└── HUD  (CanvasLayer)
    └── HUDControl  (Control)  ←  ui_manager.gd
        ├── TopInfo  (VBoxContainer)
        │   ├── FrameLabel   shows "Frame: X  Roll: Y"
        │   ├── ScoreLabel   running score
        │   ├── TurnLabel    status message
        │   └── MessageLabel "STRIKE!" / "SPARE!" flashes
        └── BottomControls  (VBoxContainer)
            ├── AimLabel     live aim angle
            └── PowerLabel   power percentage
```

---

## Script Reference

### `game_manager.gd` → `Main` (Node3D)
Central controller.  Manages a `State` enum (`AIMING → ROLLING → SCORING → GAME_OVER`), stores every roll result, calculates official 10-frame bowling scores with full strike/spare look-ahead bonus, and handles the 10th-frame bonus-roll rules.

### `isometric_camera.gd` → `IsometricCamera` (Camera3D)
Keeps the camera at a fixed isometric angle (`camera_height`, `camera_distance`).  After the throw it gently lerps toward the ball's Z position with configurable `follow_strength`, then returns to the overview position when the ball stops.

### `bowling_ball.gd` → `BowlingBall` (RigidBody3D)
Reads `aim_left` / `aim_right` / `increase_power` / `decrease_power` / `throw_ball` input actions.  Applies a directional impulse (`launch power × mass`) at throw time, adds optional angular-velocity spin, emits `ball_thrown` and `ball_stopped` signals, and cleanly resets between rolls.

### `bowling_pin.gd` → each `BowlingPin` (RigidBody3D)
Each frame checks tilt angle and displacement from spawn.  Emits `pin_knocked` once the thresholds are exceeded.  `reset_pin()` teleports the pin back and briefly freezes it so physics can settle.

### `pin_manager.gd` → `PinManager` (Node3D)
Reads `PIN_OFFSETS` (standard equilateral triangle formation, 0.305 m spacing) to place 10 pins.  Exposes `enable_detection()`, `get_knocked_count()`, `reset_knocked_count()`, `reset_all_pins()`, and `enable_detection_after_reset()`.

### `ui_manager.gd` → `HUDControl` (Control)
Thin wrapper that updates labels.  `show_message()` triggers a timed auto-clear.

---

## Bowling Dimensions Used

| Element | Dimension |
|---------|-----------|
| Lane length | 18 m |
| Lane width | 1.05 m |
| Gutter width | 0.25 m |
| Ball radius | 0.108 m (official) |
| Ball mass | 6 kg |
| Pin height | 0.38 m |
| Pin spacing | 0.305 m (standard 12 in) |
| Pin front row Z | 13.5 m from foul line |

