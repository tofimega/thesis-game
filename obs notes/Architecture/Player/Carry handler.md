- Controlled by [[Movement state machine]]

## Overview
- Three conditions must be true to spawn a bomb:
	1. The player must be in one of these states: STANDING, WALKING
	2. No bombs are on the playing field (the player must not be carrying a bomb)
	3. Enough time has passed since the last bomb has exploded (~.5s)

- Conditions to throw bomb:
	1. The player must be in one of these states: STANDING, WALKING
	2. The player must be carrying a bomb

## Incoming Data
- Is the player hurt? (must drop bomb if so)

## Outgoing data
- Did the player successfully spawn/throw bomb? (state machine must change to appr state)