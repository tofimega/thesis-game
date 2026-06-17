
# Overview
- Also saves and loads
- stores data in a PackedByteArray indexed with an enum (SaveFlag)
# Save Format
- Header (Dict(String, Variant))
	- Stores data about the save file:
		- timestamp
		- completion state
		- etc
- Flags (PackedByteArray):
	- Indexed via SaveFlag enum

- Stored in binary file at user://saves/{index}.save
# Incoming Data
- None
# Outgoing Data
- signals:
	- state_updated(flag: SaveFlag, value: int)
		- emitted when a flag is changed via update_flag
	- begin_save
		- emitted from save_game when save operation begins
	- finish_save(error: Error)
		- emitted when save operation finishes
	- begin_load
	- finish_load(error: Error)
# Interface

- update_flag(flag: SaveFlag, value, int) -> void:
	- sets the given flag to a specific value
- save_game() -> void:
	- regenerates header and saves current state to file
- load_game(index: int) -> void:
	- load save from file or create new save if none exists at index
- get_save_header(index: int) -> Dict(String, Variant):
	- parse header of save file
	- returns empty header if none exists at index


