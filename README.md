# Pixalia — Isometric Bowling Game

A fully playable isometric 10-pin bowling game built with **Godot 4.x** and **GDScript**.

## Requirements

- **Godot 4.2** or later (download from [godotengine.org](https://godotengine.org/download))
- No addons or external assets required — everything uses built-in primitives

## How to Open and Run

1. Clone or download this repository
2. Open **Godot 4** and click **Import**
3. Navigate to the repository folder and select `project.godot`
4. Click **Import & Edit**
5. Press **F5** (or click the **Play** button) to run the game

## Controls

| Action | Key |
|---|---|
| Aim left / right | ← / → Arrow Keys |
| Charge power | Hold **Space** |
| Release / Bowl | Release **Space** |
| Spin left (during roll) | **A** |
| Spin right (during roll) | **D** |

## Scenes

| Scene | Path | Description |
|---|---|---|
| Main Menu | `scenes/MainMenu.tscn` | Title screen with Play / Quit |
| Game | `scenes/Game.tscn` | Bowling gameplay |
| Game Over | `scenes/GameOver.tscn` | Final score with Restart / Quit |

## Project Structure

```
Pixalia/
├── project.godot          # Godot project config
├── export_presets.cfg     # Windows + Web export presets
├── scenes/                # All .tscn scene files
├── scripts/               # All .gd script files
├── assets/placeholder/    # Placeholder asset directory (meshes generated in-scene)
├── resources/             # Future materials/themes
├── README.md
├── EXPORT_NOTES.md        # Step-by-step export guide
├── TODO.md                # Polish wishlist
└── TEST_CHECKLIST.md      # Manual QA checklist
```

## How to Export for Windows

See [`EXPORT_NOTES.md`](EXPORT_NOTES.md) for detailed instructions.

**Quick summary:**
1. In Godot, go to **Project → Export**
2. Select the **Windows Desktop** preset
3. Download export templates if prompted
4. Click **Export Project**

## Web Export (Optional)

The `export_presets.cfg` includes a **Web** preset. See [`EXPORT_NOTES.md`](EXPORT_NOTES.md) for notes on CORS headers and COOP/COEP requirements for browser deployment.

## Scoring

Standard 10-frame bowling rules:
- **Strike** (all 10 on first roll): 10 + next 2 rolls
- **Spare** (all 10 across 2 rolls): 10 + next 1 roll
- **10th frame**: up to 3 rolls if strike or spare achieved
- **Perfect game**: 300
A new isometric game. 
