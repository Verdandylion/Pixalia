# TODO — Polish Items

A list of improvements to make Pixalia feel complete and polished.

## Audio
- [ ] Add ball rolling sound effect (looping, pitch-scaled by speed)
- [ ] Add pin collision sound (impact clack)
- [ ] Add strike/spare celebration sound
- [ ] Add background ambient sound or music
- [ ] Add UI button click sounds

## Visual Polish
- [ ] Replace CylinderMesh pins with a proper low-poly pin model
- [ ] Replace SphereMesh ball with a proper bowling ball model (finger holes)
- [ ] Add a pin impact particle effect (small debris burst)
- [ ] Add a ball trail/motion blur shader
- [ ] Improve lane textures (wood grain, arrows, dots)
- [ ] Animate the power meter with a color gradient (green → yellow → red)
- [ ] Add per-frame score display (scorecard UI)

## Gameplay
- [ ] Multiple camera presets (isometric, behind-ball, top-down)
- [ ] Local 2-player support (alternating turns)
- [ ] AI bowler for practice / single-player challenge
- [ ] Ball curve/hook mechanic (more realistic spin physics)
- [ ] Gutter detection and gutter ball feedback
- [ ] Frame-by-frame scorecard visible on HUD
- [ ] High score saving (using Godot's `FileAccess`)

## UX / Settings
- [ ] Settings menu (volume sliders, fullscreen toggle)
- [ ] Pause menu (accessible mid-game)
- [ ] Animated transitions between scenes
- [ ] Accessibility: larger font option, colorblind-friendly palette
- [ ] Controller/gamepad support

## Technical
- [ ] Unit tests for `scoring.gd` edge cases (perfect game, gutter game, etc.)
- [ ] Object pooling for pin RigidBody3D nodes
- [ ] Separate audio bus layout resource
- [ ] CI/CD pipeline for automated export
