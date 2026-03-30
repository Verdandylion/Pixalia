You are helping build a complete Godot 4 game repository.

Project goals:
- Build a small but complete isometric bowling game
- Engine: Godot 4.x
- Language: GDScript only
- Platform targets: Windows desktop first, optional Web export second
- Art style: clean stylized prototype using placeholder assets
- Camera: fixed isometric-style 3D camera
- Scope: fully playable prototype with menu, gameplay loop, scoring, sound hooks, and export configuration

Non-negotiable rules:
- Do not switch engines
- Do not use C#
- Do not use addons unless explicitly requested
- Keep all code beginner-readable
- Favor small, single-responsibility scripts
- When changing a script, rewrite the full updated file
- Always include the exact file path for every file you create
- Always explain any manual steps required in the Godot editor
- Use placeholder meshes and generated primitives where possible
- Prefer deterministic scene structure over clever abstractions

Repository expectations:
- The repo must be runnable as a Godot 4 project
- Include project.godot-compatible structure
- Include scenes, scripts, placeholder assets, and export notes
- Include a README with setup, run, and export instructions
- Include a TODO list for polish items
- Include a test checklist for manual gameplay testing

Coding standards:
- snake_case for variables and functions
- PascalCase for scene names and class-like resources only where appropriate
- No giant scripts unless unavoidable
- Use typed GDScript when reasonable
- Add brief comments only where they improve clarity
- Avoid hidden dependencies between nodes

Gameplay rules:
- Standard 10-pin bowling
- 10-frame scoring
- Correct strike, spare, and 10th-frame rules
- One player first, local multiplayer optional
- Ball can be aimed, powered, and optionally given spin
- Pins should be detected as standing or fallen robustly
- Game flow states should be explicit

Response style:
- Be concrete
- Do not skip steps
- Do not say “you can do X”; choose one best approach and implement it
- If something is missing, create it
- If editor setup is needed, list exact nodes and exact names
