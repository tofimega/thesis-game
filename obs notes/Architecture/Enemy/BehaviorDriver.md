Extends Node
## Notes
- Has to control [[Damage Taker]]'s activity
- Also everything related to the enemy


# Overview
- Acts as a state machine
- Unlike the player's state machine, it needs to be flexible to handle many different types of behaviors
- It also controls the enemy's immunity to bombs via [[Damage Taker]]


# Incoming Data
- Reference to [[Damage Taker]]
- States: Array\[[[EnemyState]]]

# Outgoing Data
- None

