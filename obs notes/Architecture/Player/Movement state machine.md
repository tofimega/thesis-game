- Requires (states, [[Damage Taker]], [[Carry handler]])

## Notes
- Handles movement states and associated animation states

- Doesn't use Nodes as states, there is no need for that


## Overview

- Behavior is a bit unusual:
	- Rather than the state defining which states it can switch to, each state has a condition under which it is 'valid' to be processed. Every cycle, the machine checks each state according to a priority order, and the first valid state is processed that frame.

- States:
	- STANDING
		- when nothing else is happening
		- plays idle animation
	- WALKING
		- Entered when player sends walk input
		- locomotion
		- needs reference to carry handler, as walking speed is slower if player carries bomb
	- HURT
		- when hurt
		- pushed back a bit
		- ends once animation is over
	- ANIMATING
		- Plays an animation, inputs are ignored
		- used when the player spawns, creates bomb, throws bomb, dies, despawns
		- Subtypes:
			- SPAWNING
				- when player spawns in after screen transition
			- DEAD
				- when player dies
			- DESPAWNING
				- when player despawns after room clear
			- PICKUP_BOMB
				- when player creates a bomb
			- THROW_BOMB
				- when plyer throws bomb

- Priority:
	1. SPAWN: the machine starts here. is 'spawn' anim playing?
	2. DESPAWN: is screen clear?
	3. DEAD: is player dead?
	4. HURT: is 'hurt' anim playing?
	5. THROW_BOMB: is 'throw' anim playing?
	6. PICKUP_BOMB: is 'pickup' anim playing?
	7. WALK: is player moving?
	8. IDLE: true
