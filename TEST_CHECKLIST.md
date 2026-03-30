# Test Checklist — Pixalia Bowling

Manual test cases for verifying correct game behaviour. Check each item after a full playthrough.

## Launch & Navigation
- [ ] Game launches to main menu
- [ ] Title and subtitle text visible on main menu
- [ ] **Play** button starts the game (transitions to Game scene)
- [ ] **Quit** button exits the application

## Aiming Phase
- [ ] Ball appears at start position (behind foul line)
- [ ] Left arrow key moves ball to the left
- [ ] Right arrow key moves ball to the right
- [ ] Ball cannot move past the lane edges (clamped)

## Charging Phase
- [ ] Holding **Space** activates the power meter
- [ ] Power meter oscillates smoothly 0 → 100 → 0
- [ ] Prompt text updates to "Release SPACE to bowl!"

## Rolling Phase
- [ ] Releasing **Space** launches the ball forward
- [ ] Ball speed corresponds to power meter value (low = slow, high = fast)
- [ ] **A** key applies left spin during roll
- [ ] **D** key applies right spin during roll
- [ ] Ball rolls along the lane and does not fall through the floor

## Pin Physics
- [ ] 10 pins are visible in a triangle formation at the far end of the lane
- [ ] Pins fall on ball impact using physics
- [ ] Fallen pins counted correctly after settling
- [ ] Standing pins remain standing after non-strike roll

## Scoring
- [ ] Score label updates after each roll
- [ ] Frame label shows correct current frame (1–10)
- [ ] Roll label shows correct roll number within frame
- [ ] **Strike** detected: all 10 pins on first roll → frame advance
- [ ] **Spare** detected: remaining pins cleared on second roll → frame advance
- [ ] Strike score = 10 + next 2 rolls (verify with two consecutive strikes)
- [ ] Spare score = 10 + next 1 roll
- [ ] Normal frame score = roll 1 + roll 2

## 10th Frame
- [ ] 10th frame allows up to 3 rolls on strike
- [ ] 10th frame allows 3rd roll on spare
- [ ] 10th frame ends after 2 rolls if no strike or spare
- [ ] Pins reset after strike in 10th frame before bonus rolls

## Game Over
- [ ] Game transitions to Game Over screen after 10th frame completion
- [ ] Final score displayed correctly on Game Over screen
- [ ] **Restart** button resets state and starts a new game
- [ ] **Quit** button exits the application

## Edge Cases
- [ ] Gutter ball (0 pins) recorded correctly
- [ ] Perfect game (12 consecutive strikes) scores 300
- [ ] All-gutter game scores 0
- [ ] Game does not crash on any normal play sequence
